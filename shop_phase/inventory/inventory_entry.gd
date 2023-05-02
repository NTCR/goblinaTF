extends HBoxContainer

const DRAG_PREVIEW = preload("res://shop_phase/drag_and_drop/drag_preview.tscn")

@export_category("Components:")
@export var artifact_image : TextureRect
@export var artifact_name : Label

var _artifact_id

func set_artifact_image(_image_path):
	artifact_image.texture = load(_image_path)
	
func set_artifact_name(_name):
	artifact_name.text = _name

func set_artifact_id(_id):
	_artifact_id = _id
	
func _get_drag_data(_at_position):
	var _preview = DRAG_PREVIEW.instantiate()
	_preview.texture = artifact_image.texture
	get_tree().current_scene.add_child(_preview)
	return _artifact_id
	
