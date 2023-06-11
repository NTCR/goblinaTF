extends Control

const ARTIFACT_BUTTON = preload("res://shop_phase/ui/artifact_box/artifact_box_selection.tscn")

signal panel_closed()

@export_category("Components:")
@export var transition : AnimationPlayer
@export var artifacts_container : GridContainer
@export var artifact_box : TextureRect
@export var price_label : Label
@export var price_group : Control
@export var slot_machine : AnimatedSprite2D

var _unique_inventory : Array[Artifact] = []
var _curr_artifact : Artifact = null
var _curr_price : int = 0

#estado1
func _ready():
	#transition.play("open_reveal")
	debujea()
	for _i in range(0,Database.inventory_size()):
		var _a : Artifact = Database.inventory_get_at(_i)
		if _a not in _unique_inventory and not Database.progress_is_artifact_completed(_a):
			_unique_inventory.append(_a)
	for _ua in _unique_inventory:
		var _butt_instance = ARTIFACT_BUTTON.instantiate()
		_butt_instance.setup_box(_ua)
		_butt_instance.connect("artifact_selected",Callable(self,"on_artifact_selected"))
		artifacts_container.add_child(_butt_instance)

#estado 2
func on_artifact_selected(_a : Artifact):
	_curr_artifact = _a
	artifact_box.setup_box(_curr_artifact)
	_curr_price = Database.price_tasar(_curr_artifact.rarity)
	price_label.text = str(_curr_price)
	transition.play("price_state")

#estado 1
func _on_butt_back_pressed():
	_curr_artifact = null
	_curr_price = 0
	artifact_box.free_box()
	transition.play("not_paid")

#estado 3
func _on_butt_pay_pressed():
	transition.play("big_reveal")

func _start_slot():
	#find first non discovered charm
	var _c : Charm.CHARMS = Database.progress_first_uncompleted_charm(_curr_artifact)
	slot_machine.start_slot(_c)

func _on_slot_machine_slot_ended():
	#play warning and show button
	print("ive come pretty far")
	pass # Replace with function body.

func _reset_container():
	for _box in artifacts_container.get_children():
		_box.queue_free()

func close_panel():
	panel_closed.emit()
	#transition.play("close_reveal")

func debujea():
	for _i in range(0,8):
		var _a : Artifact = Database.draw_artifact(3)
		Database.inventory_add_artifact(_a)
