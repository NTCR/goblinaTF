extends Control

const ARTIFACT_BUTTON = preload("res://shop_phase/ui/artifact_box/artifact_box_selection.tscn")
const CHARM_SLOT = preload("res://shop_phase/sell/charm_slot.tscn")

signal charm_was_complete()
signal charm_was_valid()
signal charm_was_invalid()
signal charm_returned()
signal artifact_completed(artifact)

@export_category("Components:")
@export var transition : AnimationPlayer
@export var artifacts_container : GridContainer
@export var artifact_box : TextureRect
@export var name_label : Label
@export var charm_slots : HBoxContainer
@export var charm_options : GridContainer

var _curr_artifact : Artifact = null
var _was_completed = false

#prepara estado initial
func _ready():
	debujea()
	for _i in range(0,Database.inventory_size()):
		var _a : Artifact = Database.inventory_get_at(_i)
		var _butt_instance = ARTIFACT_BUTTON.instantiate()
		_butt_instance.setup_box(_a)
		_butt_instance.connect("artifact_selected",Callable(self,"on_artifact_selected"))
		_butt_instance.add_to_group("controls")
		artifacts_container.add_child(_butt_instance)
	transition.play("open_sell")

#estado main
func on_artifact_selected(_a : Artifact):
	_curr_artifact = _a
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
		charm_was_invalid.emit()
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
		#remember party if completed
		if not _was_completed and Database.progress_is_artifact_completed(_curr_artifact):
			artifact_completed.emit(_curr_artifact)
		#USTED ESTA AQUI
		transition.play("sold")
		#gain gold, inform type of sell

func _controls_disable():
	get_tree().call_group("controls","set_disabled",true)

func _controls_enable():
	get_tree().call_group("controls","set_disabled",false)

func debujea():
	Database.gold_gained(25)
	var _a : Artifact = Database.game_artifacts["rum"]
#	Database.progress_charm_succeeded(_a, Charm.CHARMS.SOUTH)
#	Database.progress_charm_succeeded(_a, Charm.CHARMS.MAGE)
#	Database.progress_charm_failed(_a, Charm.CHARMS.SWORDS)
	Database.inventory_add_artifact(_a)
	Database.inventory_add_artifact(_a)
	
