extends Control

var _offset = Vector2()
var _color = Color()
var _preview_size = Vector2()

func _process(_delta):
	global_position = get_global_mouse_position() + _offset
	
	if Input.is_action_just_released("left_mouse"):
		queue_free()

func set_cursor_offset(_v2 : Vector2):
	_offset = _v2

func set_color(_c : Color):
	_color = _c

func set_preview_size(_v2 : Vector2):
	_preview_size = _v2

func _draw():
	draw_rect(Rect2(0, 0, _preview_size.x, _preview_size.y), _color)
