extends Control

const CELL_SIZE = 64
const N_COLUMNS = 10
const N_ROWS = 8
@export_category("Colors:")
@export_color_no_alpha var color_base
@export_color_no_alpha var color_grid
var _grid = {} #2d array. key [x,y] value null or UID object

func _ready():
	for _x in range(N_COLUMNS):
		for _y in range(N_ROWS):
			_grid[ Vector2(_x,_y) ] = null

func _can_drop_data(_at_position, _data):#check if is loot_bag artifact?
	var _preview_position = _at_position + _data.preview_offset()
	var _grid_pos = _calculate_grid_coordinates(_preview_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)) #makes interaction smoother
	#check if can be merged
	
	#check if space available 
	var _loot_size = _data.loot_size()
	if _is_grid_space_available(_grid_pos, _loot_size):
		$Preview.set_preview_position(_grid_pos * CELL_SIZE)
		$Preview.set_loot_size(_loot_size)
		$Preview.queue_redraw()
		return true
	else:
		return false

func _drop_data(_at_position, _data):
	var _preview_position = _at_position + _data.preview_offset()
	var _grid_pos = _calculate_grid_coordinates(_preview_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2))
	#position loot
	_reparent(_data)
	_data.position = _grid_pos * CELL_SIZE
	#update grid
	_set_grid_space(_grid_pos, _data.loot_size(), _data)

func _draw():
	draw_rect(Rect2(0,0,N_COLUMNS*CELL_SIZE,N_ROWS*CELL_SIZE), color_base)
	for _x in range(N_COLUMNS):
		for _y in range(N_ROWS):
			draw_rect(Rect2(_x*CELL_SIZE,_y*CELL_SIZE,CELL_SIZE,CELL_SIZE), color_grid, false, 1.0)

func _set_grid_space(_grid_position : Vector2, _grid_size : Vector2, _id):
	for _i in range(_grid_position.x, _grid_position.x + _grid_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _grid_size.y):
			_grid[ Vector2(_i, _j) ] = _id

func _is_grid_space_available(_grid_position : Vector2, _grid_size : Vector2) -> bool:
	if _grid_position.x < 0 or _grid_position.y < 0:
		return false
	if _grid_position.x + _grid_size.x > N_COLUMNS or \
			_grid_position.y + _grid_size.y > N_ROWS:
		return false
	for _i in range(_grid_position.x, _grid_position.x + _grid_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _grid_size.y):
			if _grid[ Vector2(_i, _j) ]:
				return false
	return true

func _calculate_grid_coordinates(_local_position : Vector2) -> Vector2:
	return (_local_position / CELL_SIZE).floor()
	
#func _calculate_grid_size(_size : Vector2) -> Vector2:
#	return (_size / CELL_SIZE).ceil()

func _reparent(_child: Node):
	if _child.get_parent() != self:
		var _old_parent = _child.get_parent()
		_old_parent.remove_child(_child)
		add_child(_child)
