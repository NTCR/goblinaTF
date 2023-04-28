extends HBoxContainer

const drag = preload("res://ShopPhase/drag_preview.tscn")

@export var artifact_image : TextureRect
@export var artifact_name : Label

var artifact_id

func set_artifactimage(image_path):
	artifact_image.texture = load(image_path)
	
func set_artifactname(_name):
	artifact_name.text = _name

func set_artifactid(_id):
	artifact_id = _id
	
func _get_drag_data(_at_position):
	var preview = drag.instantiate()
	preview.texture = artifact_image.texture
	get_tree().current_scene.add_child(preview)
	
	return artifact_id
	
