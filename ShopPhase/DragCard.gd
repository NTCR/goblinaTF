extends TextureRect

const drag = preload("res://ShopPhase/drag_preview.tscn")

var charm_id
var disabled = false

func set_charm(_id):
	charm_id = _id
	
func get_charm():
	return charm_id
	
func is_disabled():
	return disabled
	
func disable_drag():
	disabled = true
	modulate.a = 0.5

func _get_drag_data(at_position):
	if disabled:
		return
	var preview = drag.instantiate()
	preview.texture = texture
	get_tree().current_scene.add_child(preview)
	
	return charm_id
