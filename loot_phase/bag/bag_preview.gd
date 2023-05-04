extends Control

var _preview_position := Vector2(0,0)
var _loot_size := Vector2(0,0)

func set_preview_position(_pos):
	_preview_position = _pos

func set_loot_size(_size):
	_loot_size = _size

func _draw():
	draw_rect(Rect2(_preview_position.x, _preview_position.y, \
			_loot_size.x * get_parent().CELL_SIZE, _loot_size.y * get_parent().CELL_SIZE),
			Color.BLACK, false, 3.0)
