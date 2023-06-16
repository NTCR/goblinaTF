extends Control

signal panel_closed()

@export_category("Components:")
@export var transitions : AnimationPlayer

func _ready():
	transitions.play("open_panel")

func _input(_event):
	if _event is InputEventMouseButton and not get_global_rect().has_point(_event.global_position):
		transitions.play("close_panel")

func emit_close():
	panel_closed.emit()
