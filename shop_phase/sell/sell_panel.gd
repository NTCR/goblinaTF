extends Control

const ARTIFACT_BUTTON = preload("res://shop_phase/ui/artifact_box/artifact_box_selection.tscn")
const CHARM_SLOT = preload("res://shop_phase/sell/charm_slot.tscn")

signal panel_closed()
signal begin_main()
signal charm_was_complete()
signal charm_was_valid()
signal charm_was_invalid(patience_cost)
signal charm_returned()
signal artifact_sold()
signal artifact_completed(artifact)

@export_category("Components:")
@export var transition : AnimationPlayer
@export var artifacts_container : GridContainer
@export var artifact_box : TextureRect
@export var name_label : Label
@export var charm_slots : HBoxContainer
@export var charm_options : GridContainer
@export var price_label : Label
@export var sold_label : Label
@export var priceleft_label : Label

var _curr_artifact : Artifact = null
var _was_completed = false
var _gold_gain = 0

#prepara estado initial
func _ready():
	for _i in range(0,Database.inventory_size()):
		var _a : Artifact = Database.inventory_get_at(_i)
		var _butt_instance = ARTIFACT_BUTTON.instantiate()
		_butt_instance.setup_box(_a)
		_butt_instance.connect("artifact_selected",Callable(self,"on_artifact_selected"))
		_butt_instance.add_to_group("controls")
		artifacts_container.add_child(_butt_instance)
	transition.play("open_sell")

func _on_butt_go_loot_pressed():
	panel_closed.emit()
	transition.play("close_sell")

#estado main
func on_artifact_selected(_a : Artifact):
	begin_main.emit()
	_curr_artifact = _a
	Database.inventory_erase_artifact(_curr_artifact)
	_was_completed = Database.progress_is_artifact_completed(_curr_artifact)
	artifact_box.free_box()
	artifact_box.setup_box(_curr_artifact)
	name_label.text = _curr_artifact.name
	var _color = LootBag.TIER_COLORS[_curr_artifact.rarity+1]
	name_label.add_theme_color_override("font_color",_color)
	
	for _i in range(0,_curr_artifact.charms_complete.size()):
		var _slot_instance = CHARM_SLOT.instantiate()
		_slot_instance.slot_setup()
		_slot_instance.connect("charm_selected",Callable(self,"_slot_pressed"))
		_slot_instance.add_to_group("controls")
		charm_slots.add_child(_slot_instance)
	
	var _ordered_charms : Array[Charm.CHARMS] = []
	var _last_perfect : int = 0
	var _last_undiscovered : int = 0
	for _c in Charm.CHARMS.values():
		if Database.progress_has_charm_succeeded(_curr_artifact, _c):
			_last_perfect += 1
			_last_undiscovered += 1
			_ordered_charms.push_front(_c)
		elif Database.progress_has_charm_failed(_curr_artifact, _c):
			_ordered_charms.push_back(_c)
		else:
			_last_undiscovered += 1
			_ordered_charms.insert(_last_perfect, _c)
	
	for _i in range(0,_ordered_charms.size()):
		var _c = _ordered_charms[_i]
		var _option_instance = CHARM_SLOT.instantiate()
		_option_instance.butt_setup(_c)
		_option_instance.connect("charm_selected",Callable(self,"_icon_pressed"))
		if _i < _last_perfect:
			_option_instance.butt_preference()
		elif _i < _last_undiscovered:
			_option_instance.butt_undiscovered()
		else:
			_option_instance.butt_invalid()
		_option_instance.add_to_group("controls")
		charm_options.add_child(_option_instance)
	
	transition.play("begin_main")

func _slot_pressed(_cs : CharmSlot):
	charm_returned.emit()
	var _option_instance = CHARM_SLOT.instantiate()
	_option_instance.butt_setup(_cs.get_charm())
	_option_instance.connect("charm_selected",Callable(self,"_icon_pressed"))
	_option_instance.butt_preference()
	_option_instance.add_to_group("controls")
	charm_options.add_child(_option_instance)
	var _recently_added = charm_options.get_child(charm_options.get_child_count()-1)
	charm_options.move_child(_recently_added,0)
	_cs.slot_empty()

func _icon_pressed(_cs : CharmSlot):
	var _valid : bool = true
	var _charm : Charm.CHARMS = _cs.get_charm()
	if _charm in _curr_artifact.charms_complete:
		charm_was_complete.emit()
	elif _charm in _curr_artifact.charms_valid:
		charm_was_valid.emit()
	else:
		var _patience_cost = Database.patience_cost(_curr_artifact.rarity)
		charm_was_invalid.emit(_patience_cost)
		_valid = false
		
	if _valid:
		Database.progress_charm_succeeded(_curr_artifact, _charm)
		var _slot : CharmSlot = _find_empty_slot()
		_slot.slot_fill(_charm)
		_cs.queue_free()
		#check if end
		_is_artifact_sold()
	else:
		Database.progress_charm_failed(_curr_artifact, _charm)
		_cs.butt_invalid()
		charm_options.move_child(_cs,charm_options.get_child_count()-1)

func _find_empty_slot() -> CharmSlot:
	for _slot in charm_slots.get_children():
		if _slot.slot_is_empty():
			return _slot
	return null

func _is_artifact_sold():
	if not _find_empty_slot():
		artifact_sold.emit()
		#remember party if completed
		if not _was_completed and Database.progress_is_artifact_completed(_curr_artifact):
			artifact_completed.emit(_curr_artifact)
		#ver si venta valida o perfecta
		var _completed_sell = true
		var _charms_in_slots : Array[Charm.CHARMS] = []
		for _slot in charm_slots.get_children():
			_slot.slot_lock()
			_charms_in_slots.append(_slot.get_charm())
		for _charm in _curr_artifact.charms_complete:
			if _charm not in _charms_in_slots:
				_completed_sell = false
		
		if _completed_sell:
			sold_label.text = "¡Has vendido el artefacto a su mejor precio!"
			_gold_gain = Database.price_sell(_curr_artifact.rarity, false, true)
			price_label.text = str(_gold_gain)
		else:
			sold_label.text = "Has vendido el artefacto a un buen precio."
			_gold_gain = Database.price_sell(_curr_artifact.rarity, false, false)
			price_label.text = str(_gold_gain)
		transition.play("sold")

func _on_sold_butt_pressed():
	#add gold, reset all vars, intial state, elimina un butt artifact adecuado
	Database.gold_gained(_gold_gain)
	for _artf_butt in artifacts_container.get_children():
		if _curr_artifact == _artf_butt.get_artifact():
			_artf_butt.queue_free()
			break
	_curr_artifact = null
	_was_completed = false
	_gold_gain = 0
	transition.play("back_initial")

func merchant_is_leaving():
	_gold_gain = Database.price_sell(_curr_artifact.rarity, true)
	Database.gold_gained(_gold_gain)
	priceleft_label.text = str(_gold_gain)
	transition.play("merchant_left")

func can_leave():
	_controls_enable()

func _clean_main():
	for _slot in charm_slots.get_children():
		_slot.queue_free()
	for _option in charm_options.get_children():
		_option.queue_free()
	artifact_box.free_box()

func _controls_disable():
	get_tree().call_group("controls","set_disabled",true)

func _controls_enable():
	get_tree().call_group("controls","set_disabled",false)
	





