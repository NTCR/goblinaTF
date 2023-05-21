extends Control

const LOOT_BAG : Resource = preload("res://loot_phase/loot_bag.tscn")
const LOOT_TEXTURES = {
	1 : "res://loot_phase/loot/crate_common.png",
	2 : "res://loot_phase/loot/crate_uncommon.png",
	3 : "res://loot_phase/loot/crate_unique.png",
	4 : "res://loot_phase/loot/crate_epic.png",
	}
const DIRECTIONS = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
const CELL_SIZE = 144
const N_COLUMNS = 5
const N_ROWS = 4
var _grid = {} #state: free or not
@onready var _grid_origin_position : Vector2 = $BagGrid.position.round()
@onready var _grid_end_position : Vector2 = $BagGrid.size
@onready var _loot_held : Loot_Holder = Loot_Holder.new()
@onready var _loot_in_bag : Array[LootBag]

func _ready():
	for _x in range(N_COLUMNS):
		for _y in range(N_ROWS):
			_grid[ Vector2(_x,_y) ] = false

func _process(_delta):
	var _mouse_global_position = get_global_mouse_position()
	if _loot_held.is_held() and get_global_rect().has_point(_mouse_global_position):
		var _loot_in_position = _loot_is_on_global_position(_mouse_global_position)
		var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
		var _loot_info : Loot = _loot_held.loot
		var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_info.size_cells)
		#if on loot -> mark loot if can merge or swap
		if _loot_in_position:
			$BagGrid/Preview.position = _grid_coordinates_to_local(_loot_in_position.grid_position)
			$BagGrid/Preview.size = _loot_in_position.loot_contained.size_cells * CELL_SIZE
			$BagGrid/Preview.visible = true
		#if slot valid -> mark slot candidate
		#if empty - size held and preview pos
		elif _grid_is_coordinates_valid(_candidate_pos):
			$BagGrid/Preview.position = _grid_coordinates_to_local(_candidate_pos)
			$BagGrid/Preview.size = _loot_info.size_cells * CELL_SIZE
			$BagGrid/Preview.visible = true
		#if occupied - size current artifact and its pos
		#if none -> INVALID
		else:
			$BagGrid/Preview.visible = false
	else:
		$BagGrid/Preview.visible = false

func _exit_tree():
	_loot_held.free()

func _input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		var _mouse_global_position = _event.global_position
		if get_global_rect().has_point(_mouse_global_position):
			var _loot_in_mouse = _loot_is_on_global_position(_mouse_global_position)
			if _event.pressed:
			#grab
				#hay alguien debajo mouse?
				if _loot_in_mouse:
					var _loot_size = _loot_in_mouse.loot_contained.size_cells
					var _loot_tier = _loot_in_mouse.loot_contained.tier
					#calculate offset
					var _corner_right_up = _grid_coordinates_to_local(_loot_in_mouse.grid_position) + _grid_origin_position
					var _mouse_local_position = _mouse_global_position - get_global_rect().position
					var _mouse_offset = _mouse_local_position - _corner_right_up
					#genera drag
					var _drag_instance = DragPreview.new()
					var _desired_size = Vector2(CELL_SIZE*_loot_size[0], CELL_SIZE*_loot_size[1])
					_drag_instance.create_drag(LOOT_TEXTURES[_loot_tier], _desired_size,_mouse_offset)
					get_tree().current_scene.add_child(_drag_instance)
					#asignar loot held
					_loot_held.grab(_loot_in_mouse.loot_contained, _mouse_offset)
					#elimina loot
					_loot_remove(_loot_in_mouse)
			elif _loot_held.is_held(): #mouse realeased and loot held
			#drop
				var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
				var _loot_size = _loot_held.loot.size_cells
				var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_size)
				#mouse on loot
				if _loot_in_mouse:
					#A.merge
					#B.swap
					pass
				#mouse on slot
				#A.free slot
				elif _grid_is_coordinates_valid(_candidate_pos):
					#add loot to bag
					_loot_add(_candidate_pos)
		#mouse released
		if not _event.pressed and _loot_held.is_held():
			_loot_held_release()

#PENDING
func _loot_held_release():
	_loot_held.release()

func _loot_add(_grid_pos : Vector2):
	var _loot_info : Loot = _loot_held.loot
	var _loot_instance : LootBag = LOOT_BAG.instantiate()
	_loot_instance.texture = load(LOOT_TEXTURES[_loot_info.tier])
	_loot_instance.size = _loot_info.size_cells * CELL_SIZE
	_loot_instance.configure_loot(_loot_info) #CHECK LATER
	_loot_instance.set_grid_pos(_grid_pos)
	_loot_instance.position = _grid_coordinates_to_local(_grid_pos)
	$BagGrid/LootContainer.add_child(_loot_instance)
	_loot_in_bag.append(_loot_instance)
	#marco ocupado
	_grid_set_space(_grid_pos,_loot_info.size_cells, true)

func _loot_remove(_loot : LootBag):
	_loot_in_bag.erase(_loot)
	_grid_set_space(_loot.grid_position, _loot.loot_contained.size_cells, false)
	_loot.queue_free()

func _loot_is_on_global_position(_global_position : Vector2) -> LootBag:
	for _loot in _loot_in_bag:
		if _loot.get_global_rect().has_point(_global_position):
			return _loot
	return null

#func _reparent(_child: Node): #SERIA SPAWN LOOT O ALGO ASI
#	if _child.get_parent() != self:
#		var _old_parent = _child.get_parent()
#		_old_parent.remove_child(_child)
#		add_child(_child)

func _grid_set_space(_grid_position : Vector2, _loot_size : Vector2, _state : bool):
	for _i in range(_grid_position.x, _grid_position.x + _loot_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _loot_size.y):
			_grid[ Vector2(_i, _j) ] = _state

func _grid_find_space_available(_grid_position : Vector2, _loot_size : Vector2i) -> Vector2:
	var _final_pos = Vector2(-1,-1)
	if _grid[ Vector2(_grid_position.x, _grid_position.y) ]: #interaccion merge etc
		return _final_pos
	
	var _directions : Array[int] = [_loot_size.x-1, _loot_size.x-1, _loot_size.y-1, _loot_size.y-1]
	var _min_size : int = _loot_size.x * _loot_size.y
	var _path = _path_recursive_finding(_grid_position, [], [], _directions.duplicate(true), _min_size)
	if _path.size() >= _min_size:
		#valid
		#find origin
		return _path_node_closest_origin(_path)
	else:
		return _final_pos

#directions must always be size 4
func _path_recursive_finding(_grid_position : Vector2, _visited : Array[Vector2],
		_shortest : Array[Vector2], _directions : Array[int], _min_size : int) -> Array[Vector2]:
	#visitados -> current path
	_visited.append(_grid_position)
	for _cardinal in range(0,_directions.size()):
		if _directions[_cardinal] > 0:
			var _next_position = _grid_position + DIRECTIONS[_cardinal]
			if _path_node_check_valid(_next_position, _visited):
				_directions[_cardinal] -= 1
				var _candidate_path = _path_recursive_finding(_next_position, _visited.duplicate(true), _shortest.duplicate(true), _directions.duplicate(true), _min_size)
				_shortest = _candidate_path
	#check conditions
	if _visited.size() >= _min_size:
		if _shortest.size() < _min_size or _shortest.size() > _visited.size():
			return _visited
		else:
			return _shortest
	else:
		return _shortest

func _path_node_check_valid(_grid_position : Vector2, _visited : Array) -> bool:
	if _grid_position.x < 0 or _grid_position.y < 0 or _grid_position.x >= N_COLUMNS or _grid_position.y >= N_ROWS:
			return false
	if _grid[ Vector2(_grid_position.x, _grid_position.y)]:
		return false
	if _grid_position in _visited:
		return false
	return true

func _path_node_closest_origin(_path : Array[Vector2]) -> Vector2:
	var _origin = _path[0]
	for _pos in _path:
		if _origin.length() > _pos.length():
			_origin = _pos
	return _origin

func _grid_is_coordinates_valid(_grid_position : Vector2) -> bool:
	return _grid_position != Vector2(-1,-1)

func _grid_drop_coordinates(_mouse_global_position : Vector2) -> Vector2:
	var _bag_rect = get_global_rect()
	var _grid_rect = $BagGrid.get_global_rect()
	var _local_position = _mouse_global_position - _bag_rect.position
	var _half_a_cell = float(CELL_SIZE)/2
	var _loot_size = _loot_held.loot.size_cells * CELL_SIZE
	
	#mouse offset based in corner right up
	#determine corners -> offset finds initial corner (right_up), next find the other corners
	var _corner_left_up = _local_position - _loot_held.offset
	var _corner_left_down = Vector2(_corner_left_up.x, _corner_left_up.y + _loot_size.y)
	var _corner_right_up = Vector2(_corner_left_up.x + _loot_size.x, _corner_left_up.y)
	var _corner_right_down = _corner_left_up + _loot_size
	#determine anchors -> half a cell is corrected to improve interaction to each corner
	var _anchor_left_up = _corner_left_up + Vector2(_half_a_cell, _half_a_cell)
	var _anchor_left_down = _corner_left_down + Vector2(_half_a_cell, -_half_a_cell)
	var _anchor_rigt_up = _corner_right_up + Vector2(-_half_a_cell, _half_a_cell)
	var _anchor_right_down = _corner_right_down + Vector2(-_half_a_cell, -_half_a_cell)
	
	#use by default left up anchor
	_local_position = _anchor_left_up
	#grid is split in 4 quadrants. if an specific qudrant its anchors is out of bounds, use that anchor
	var _out_of_boud = _grid_end_position + _grid_origin_position
	var _grid_mid_point_x = _grid_rect.size.x/2 + _grid_origin_position.x
	var _grid_mid_point_y = _grid_rect.size.y/2 + _grid_origin_position.y
	
	if(_local_position.x >= _grid_mid_point_x):
		if(_local_position.y > _grid_mid_point_y):
			#inferior derecha
			if _anchor_right_down.x >= _out_of_boud.x or _anchor_right_down.y >= _out_of_boud.y:
				_local_position = _anchor_right_down
		else:
			#superior derecha
			if _anchor_rigt_up.x >= _out_of_boud.x or _anchor_rigt_up.y <= _grid_origin_position.y:
				_local_position = _anchor_rigt_up
	else:
		if(_local_position.y > _grid_mid_point_y):
			#inferior izquierda
			if _anchor_left_down.x <= _grid_origin_position.x or _anchor_left_down.y >=_out_of_boud.y:
				_local_position = _anchor_left_down
	
	var _snapd_position = _local_position.clamp(_grid_origin_position, _grid_end_position)
	var _baggrid_position = _snapd_position - _grid_origin_position #from local to grid local
	return _grid_coordinates_from_local(_baggrid_position)

func _grid_coordinates_to_local(_grid_position : Vector2) -> Vector2:
	return _grid_position * CELL_SIZE

func _grid_coordinates_from_local(_local_position : Vector2) -> Vector2:
	return (_local_position / CELL_SIZE).floor()

func _on_crate_looted(_crate_loot : Loot, _mouse_offset : Vector2):
	_loot_held.grab(_crate_loot,_mouse_offset)

class Loot_Holder:
	var loot : Loot
	var offset : Vector2
	var original_grid_pos : Vector2
	
	func _init(_loot : Loot = null, _offset : Vector2 = Vector2.ZERO, _pos : Vector2 = Vector2(-1,-1)):
		if _loot:
			loot = Loot.new()
			loot.copy(_loot)
		else:
			loot = null
		offset = _offset
		original_grid_pos = _pos
	
	func release():
		loot.free()
		loot = null
		offset = Vector2.ZERO
		original_grid_pos = Vector2(-1,-1)
	
	func grab(_loot : Loot, _offset : Vector2, _pos : Vector2 = Vector2(-1,-1)):
		loot = Loot.new()
		loot.copy(_loot)
		offset = _offset
		original_grid_pos = _pos

	func is_held():
		return loot != null
	
	func is_from_crate():
		return original_grid_pos == Vector2(-1,-1)

