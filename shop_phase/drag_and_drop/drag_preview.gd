extends Sprite2D

var mouse_offset := Vector2()

func _process(_delta):
	global_position = get_global_mouse_position() - mouse_offset

func _input(_event):
	if _event is InputEventMouseButton \
			and _event.button_index == MOUSE_BUTTON_LEFT \
			and not _event.pressed:
		queue_free()
