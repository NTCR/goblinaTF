extends TextureRect

const CELL_SIZE = 32 #every cell 32x32px

var _grid_width = 0
var _grid_height = 0
var _grid = {}  

func _ready():
	var _size = _get_grid_size(self)
	_grid_width = _size.x
	_grid_height = _size.y
 
	for _x in range(_grid_width): #setup 2d array, for now is a 2d dictionary, or a linked hash table
		_grid[_x] = {}
		for _y in range(_grid_height):
			_grid[_x][_y] = false
 
func insert_artifact(_artifact):
	var _artifact_pos = _artifact.global_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2) #makes interaction smoother
	var _g_pos = _pos_to_grid_coord(_artifact_pos) #grid coordinates
	var _artifact_size = _get_grid_size(_artifact) #could be set up in meta data - ASSUMES EVERY OBJECTS is rect
	if _is_grid_space_available(_g_pos.x, _g_pos.y, _artifact_size.x, _artifact_size.y): #esta vacio
		_set_grid_space(_g_pos.x, _g_pos.y, _artifact_size.x, _artifact_size.y, true)
		_artifact.position = Vector2(_g_pos.x, _g_pos.y) * CELL_SIZE
		if _artifact.get_parent() != self:
			var _old_parent = _artifact.get_parent()
			_old_parent.remove_child(_artifact)
			add_child(_artifact) #theres move function
		return true
	#merge implementation
	var _merge_candidate = _get_artifact_under_pos(get_global_mouse_position())
	if _can_be_merged(_artifact,_merge_candidate):
		var _c_tier = _merge_candidate.get_meta("tier")
		var _c_type = _merge_candidate.get_meta("type")
		_c_tier += 1
		_merge_candidate.set_meta("tier",_c_tier)
		_merge_candidate.texture = load(LootDB.get_loot_bag(_c_type)[_c_tier])
		_artifact.queue_free()
		return true
	else:
		return false
 
func grab_artifact(_pos):
	var _artifact = _get_artifact_under_pos(_pos)
	if _artifact == null:
		return null
	var _artifact_pos = _artifact.global_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	var _g_pos = _pos_to_grid_coord(_artifact_pos)
	var _artifact_size = _get_grid_size(_artifact)
	_set_grid_space(_g_pos.x, _g_pos.y, _artifact_size.x, _artifact_size.y, false)
	_artifact.move_to_front()
	return _artifact


#PRIVATE
#global pos to grid coord
func _pos_to_grid_coord(_pos):
	var _local_pos = _pos - get_global_rect().position
	var _results = Vector2i()
	_results.x = int(_local_pos.x / CELL_SIZE)
	_results.y = int(_local_pos.y / CELL_SIZE)
	return _results

#could be calculated previously
func _get_grid_size(item):
	var _results = Vector2i()
	var _s = item.get_texture().get_size()
	_results.x = int(_s.x / CELL_SIZE)
	_results.y = int(_s.y / CELL_SIZE)
	return _results
	

func _is_grid_space_available(_x, _y, _w ,_h): #CHECK
	if _x < 0 or _y < 0: #invalid input
		return false
	if _x + _w > _grid_width or _y + _h > _grid_height:
		return false
	for _i in range(_x, _x + _w):
		for _j in range(_y, _y + _h):
			if _grid[_i][_j]:
				return false
	return true

func _can_be_merged(_artifact, _candidate):
	if _candidate == null:
		return false
	if _candidate.get_meta("tier") == LootDB.MAX_TIER:
		return false
	if _candidate.get_instance_id() == _artifact.get_instance_id():
		return false
	if _candidate.get_meta("type") == _artifact.get_meta("type") and \
			_candidate.get_meta("tier") == _artifact.get_meta("tier"):
		return true
	else:
		return false
 
func _set_grid_space(_x, _y, _w, _h, _state):
	for _i in range(_x, _x + _w):
		for _j in range(_y, _y + _h):
			_grid[_i][_j] = _state

 
func _get_artifact_under_pos(_pos):
	for _artifact in get_children():
		if _artifact.get_global_rect().has_point(_pos):
			return _artifact
	return null
