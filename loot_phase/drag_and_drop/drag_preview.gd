class_name DragPreview
extends Sprite2D

var _mouse_offset := Vector2()

func _process(_delta):
	global_position = get_global_mouse_position() - _mouse_offset

func _input(_event):
	if _event is InputEventMouseButton \
			and _event.button_index == MOUSE_BUTTON_LEFT \
			and not _event.pressed:
		queue_free()

func create_drag(_texture_path : String, _size : Vector2, _offset : Vector2):
	texture = load(_texture_path)
	scale = _size/texture.get_size()
	centered = false
	_mouse_offset = _offset
