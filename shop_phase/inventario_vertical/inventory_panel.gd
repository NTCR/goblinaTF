extends Control

const ARTIFACT_BOX = preload("res://shop_phase/inventario_vertical/inventory_artifact_box.tscn")

signal panel_closed()

@export_category("Components:")
@export var transitions : AnimationPlayer
@export var artifacts_container : GridContainer

func _ready():
	for _i in range(0,Database.inventory_size()):
		var _a : Artifact = Database.inventory_get_at(_i)
		var _box_instance = ARTIFACT_BOX.instantiate()
		_box_instance.setup_box(_a)
		artifacts_container.add_child(_box_instance)
	var _curr_gold : int = Database.gold_total()
	if _curr_gold > 9999999:
		$PanelGold/GoldLabel.text = "+9999999"
	else:
		$PanelGold/GoldLabel.text = str(_curr_gold)
	transitions.play("open_panel")

func _input(_event):
	if _event is InputEventMouseButton and not get_global_rect().has_point(_event.global_position):
		transitions.play("close_panel")

func emit_close():
	panel_closed.emit()
