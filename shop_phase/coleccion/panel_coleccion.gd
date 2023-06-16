extends Control

const COLECCION_ENTRY = preload(("res://shop_phase/coleccion/coleccion_entry.tscn"))

signal panel_closed()

@export_category("Components:")
@export var transitions : AnimationPlayer
@export var entry_container : VBoxContainer
@export var found_label : Label

func _ready():
	var _found = 0
	var _ordered_artifacts : Array[Artifact] = []
	for _key in Database.gameartifacts_names():
		var _a : Artifact = Database.gameartifacts_get_artifact(_key)
		if Database.progress_is_artifact_discovered(_a):
			_ordered_artifacts.push_front(_a)
			_found += 1
		else:
			_ordered_artifacts.push_back(null)
	for _artifact in _ordered_artifacts:
		var _entry_instance = COLECCION_ENTRY.instantiate()
		_entry_instance.setup_entry(_artifact)
		entry_container.add_child(_entry_instance)
	found_label.text = str(_found) + "/" + str(Database.gameartifacts_totaln_artifacts())
	transitions.play("open_panel")

func _input(_event):
	if _event is InputEventMouseButton and not get_global_rect().has_point(_event.global_position):
		transitions.play("close_panel")

func emit_close():
	panel_closed.emit()
