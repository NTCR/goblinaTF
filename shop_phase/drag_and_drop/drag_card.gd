extends TextureRect

const DRAG_PREVIEW = preload("res://shop_phase/drag_and_drop/drag_preview.tscn")

var _charm_id
var _is_enabled = true

func set_charm(_id):
	_charm_id = _id
	
func get_charm():
	return _charm_id
	
func is_enabled():
	return _is_enabled
	
func disable_drag():
	_is_enabled = false
	modulate.a = 0.5

func _get_drag_data(_at_position):
	if not _is_enabled:
		return
	var _preview = DRAG_PREVIEW.instantiate()
	_preview.texture = texture
	get_tree().current_scene.add_child(_preview)
	return _charm_id
