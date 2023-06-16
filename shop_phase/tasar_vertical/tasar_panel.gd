extends Control

const ARTIFACT_BUTTON = preload("res://shop_phase/ui/artifact_box/artifact_box_selection.tscn")

signal panel_closed()
signal artifact_selected(artifact)
signal artifact_deselected()

@export_category("Components:")
@export var transition : AnimationPlayer
@export var artifacts_container : GridContainer
@export var artifact_box : TextureRect
@export var price_label : Label
@export var slot_machine : AnimatedSprite2D

var _unique_inventory : Array[Artifact] = []
var _curr_artifact : Artifact = null
var _curr_price : int = 0

#prepare estado1
func _ready():
	for _i in range(0,Database.inventory_size()):
		var _a : Artifact = Database.inventory_get_at(_i)
		if _a not in _unique_inventory and not Database.progress_is_artifact_completed(_a):
			_unique_inventory.append(_a)
	for _ua in _unique_inventory:
		var _butt_instance = ARTIFACT_BUTTON.instantiate()
		_butt_instance.setup_box(_ua)
		_butt_instance.connect("artifact_selected",Callable(self,"on_artifact_selected"))
		_butt_instance.add_to_group("controls")
		artifacts_container.add_child(_butt_instance)
	transition.play("open_tasar")

#estado 2
func on_artifact_selected(_a : Artifact):
	artifact_selected.emit(_a)
	_curr_artifact = _a
	artifact_box.free_box()
	artifact_box.setup_box(_curr_artifact)
	_curr_price = Database.price_tasar(_curr_artifact.rarity)
	price_label.text = str(_curr_price)
	if _curr_price > Database.gold_total():
		$Price/InvalidLabel.visible = true
		price_label.add_theme_color_override("font_color",Color8(255,87,70))
	else:
		$Price/InvalidLabel.visible = false
		price_label.remove_theme_color_override("font_color")
	transition.play("price_state")

func check_can_pay():
	if _curr_price > Database.gold_total():
		$Price/ButtPay.disabled = true

#estado 1
func _on_butt_back_pressed():
	_back_to_select()
	transition.play("not_paid")

#estado 3
func _on_butt_pay_pressed():
	Database.gold_spend_try(_curr_price)
	transition.play("big_reveal")

func _start_slot():
	#find first non discovered charm
	var _c : Charm.CHARMS = Database.progress_first_uncompleted_charm(_curr_artifact)
	slot_machine.start_slot(_c)

func _on_slot_machine_slot_ended():
	#play warning and show button
	transition.play("accept_reveal")

#estado 1
func _on_paid():
	_unique_inventory.erase(_curr_artifact)
	_back_to_select()
	_reset_container()
	transition.play("back_select")

func close_panel():
	panel_closed.emit()
	transition.play("close_tasar")

func _back_to_select():
	artifact_deselected.emit()
	_curr_artifact = null
	_curr_price = 0

func _reset_container():
	for _box in artifacts_container.get_children():
		_box.queue_free()
	for _ua in _unique_inventory:
		var _butt_instance = ARTIFACT_BUTTON.instantiate()
		_butt_instance.setup_box(_ua)
		_butt_instance.connect("artifact_selected",Callable(self,"on_artifact_selected"))
		artifacts_container.add_child(_butt_instance)

func _controls_disable():
	get_tree().call_group("controls","set_disabled",true)

func _controls_enable():
	get_tree().call_group("controls","set_disabled",false)
