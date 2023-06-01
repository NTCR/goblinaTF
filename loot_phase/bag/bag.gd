class_name Bag
extends Control

const LOOT_BAG : Resource = preload("res://loot_phase/bag/loot_bag.tscn")
const THROW_PARTICLES = preload("res://loot_phase/effects/particle_wood.tscn")
const DIRECTIONS = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)]
const CELL_SIZE = 144
const N_COLUMNS = 5
const N_ROWS = 4
var _grid_dict = {}
@onready var loot_in_bag : Array[LootBag] #keeps references of loot in bag
@onready var _loot_held : Loot_Holder = Loot_Holder.new() #tracks if loot is held + data
@onready var _grid_origin_position : Vector2 = $BagGrid.position.round()
@onready var _grid_end_position : Vector2 = $BagGrid.size
@onready var _preview_valid = $BagGrid/PreviewValid
@onready var _preview_invalid = $BagGrid/PreviewInvalid


func _ready():
	#init grid
	for _x in range(N_COLUMNS):
		for _y in range(N_ROWS):
			_grid_dict[ Vector2(_x,_y) ] = false

func _physics_process(_delta):
	#preview functionality
	var _mouse_global_position = get_global_mouse_position()
	if _loot_held.is_held() and get_global_rect().has_point(_mouse_global_position):
		var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
		var _loot_in_position := _loot_is_in_position(_mouse_global_position, _grid_pos)
		#want to swap or merge
		if _loot_in_position:
			if _can_merge(_loot_in_position):
				_preview_valid_show(_loot_in_position.get_grid_position(),_loot_in_position.get_loot_size())
			else:
				_preview_invalid_show(_loot_in_position.get_grid_position(),_loot_in_position.get_loot_size())
		#want to insert
		else:
			var _loot_size = _loot_held.get_loot_size()
			var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_size)
			if _grid_is_coordinates_valid(_candidate_pos):
				_preview_valid_show(_candidate_pos,_loot_size)
			else:
				_preview_invalid_show(_grid_pos,_loot_size)
	else:
		_preview_hide()



func _preview_valid_show(_grid_pos : Vector2, _loot_cell_size : Vector2):
	_preview_valid.position = _grid_coordinates_to_local(_grid_pos)
	_preview_valid.size = _loot_cell_size * CELL_SIZE
	_preview_valid.visible = true
	_preview_invalid.visible = false

func _preview_invalid_show(_grid_pos : Vector2, _loot_cell_size : Vector2):
	var _fixd_pos = _invalid_fix_position(_grid_pos, _loot_cell_size)
	_preview_invalid.position = _grid_coordinates_to_local(_fixd_pos)
	_preview_invalid.size = _loot_cell_size * CELL_SIZE
	_preview_invalid.visible = true
	_preview_valid.visible = false

func _invalid_fix_position(_grid_pos : Vector2, _loot_cell_size : Vector2) -> Vector2:
	var _x_fix = _grid_pos.x + _loot_cell_size.x - N_COLUMNS
	if _x_fix > 0:
		_grid_pos.x -= _x_fix
	var _y_fix = _grid_pos.y + _loot_cell_size.y - N_ROWS
	if _y_fix > 0:
		_grid_pos.y -= _y_fix
	return _grid_pos

func _preview_hide():
	_preview_valid.visible = false
	_preview_invalid.visible = false

func _gui_input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		var _mouse_global_position = _event.global_position
		var _loot_in_mouse := _loot_is_in_global_position(_mouse_global_position)
		#GRAB
		if _event.pressed and _loot_in_mouse and not _loot_held.is_held():
			#grab interaction
			_create_drag(_loot_in_mouse, _mouse_global_position)
			#elimina loot
			_loot_remove(_loot_in_mouse)

func _create_drag(_loot_in_mouse : LootBag, _mouse_global_position : Vector2):
	#calculate size
	var _loot_size = _loot_in_mouse.get_loot_size()
	var _desired_size = _loot_size * CELL_SIZE
	#calculate offset
	var _corner_right_up = _grid_coordinates_to_local(_loot_in_mouse.get_grid_position()) + _grid_origin_position
	var _mouse_local_position = _mouse_global_position - get_global_rect().position
	var _mouse_offset = _mouse_local_position - _corner_right_up
	#genera drag
	var _drag_instance = LootDrag.new()
	_drag_instance.loot_drag_bag(self, _loot_in_mouse.get_loot(), _desired_size, _mouse_offset, _loot_in_mouse.get_grid_position())
	get_tree().current_scene.find_child("UI").add_child(_drag_instance)

func _exit_tree():
	_loot_held.free()

#llamada externa - loot drag setup
func on_loot_grab(_loot : Loot, _mouse_offset : Vector2, _grid_pos : Vector2):
	_loot_held.grab(_loot, _mouse_offset, _grid_pos)

#señal loot drag release
func _on_loot_released(_crate_ref : Crate = null):
	var _mouse_global_position = get_global_mouse_position()
	if not _loot_held.is_held(): #QUITAR DESPUES DEBUG
		print("SOMETHING WENT TERRIBLY WRONG")
		print("loot released called, but no loot held")
	if get_global_rect().has_point(_mouse_global_position):
		#DROP
		var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
		var _loot_in_position := _loot_is_in_position(_mouse_global_position, _grid_pos)
		#grid pos locked
		if _loot_in_position:
			if _can_merge(_loot_in_position):
				_loot_upgrade(_loot_in_position)
				_loot_drop_valid(_crate_ref)
			else:
				_loot_drop_invalid(_crate_ref)
		else:
			var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_held.get_loot_size())
		#A.free slot
			if _grid_is_coordinates_valid(_candidate_pos):
				#add loot to bag
				_loot_add_held(_candidate_pos)
				_loot_drop_valid(_crate_ref)
			else:
				_loot_drop_invalid(_crate_ref)
	#loot released outside rect
	else:
		_loot_thrown(_crate_ref)

func on_crate_destroyed():
	if _loot_held.is_held() and _loot_held.is_from_crate():
			_loot_held.release()

func _can_merge(_loot_in_mouse : LootBag) -> bool:
	return _loot_in_mouse.get_loot_type() == _loot_held.get_loot_type() \
			and _loot_in_mouse.get_loot_tier() == _loot_held.get_loot_tier() \
			and _loot_in_mouse.get_loot_tier()< Loot.MAX_TIER +1

func _loot_drop_valid(_crate_ref : Crate):
	if _crate_ref:
		#gestiona crate
		_crate_ref.crate_has_been_looted()
	_loot_held.release()

func _loot_drop_invalid(_crate_ref : Crate):
	if not _crate_ref:
		var _grid_pos = _loot_held.get_grid_position()
		_loot_add_held(_grid_pos)
	_loot_held.release()

func _loot_thrown(_crate_ref : Crate):
	if not _crate_ref:
		var _effect = THROW_PARTICLES.instantiate()
		_effect.global_position = get_global_mouse_position()
		get_tree().current_scene.find_child("UI").add_child(_effect)
	_loot_held.release()

func _loot_add_held(_grid_pos : Vector2):
	var _loot_info : Loot = _loot_held.get_loot()
	var _loot_instance : LootBag = LOOT_BAG.instantiate()
	_loot_instance.setup(_loot_info, _grid_pos)
	_loot_instance.position = _grid_coordinates_to_local(_grid_pos)
	$BagGrid/LootContainer.add_child(_loot_instance)
	loot_in_bag.append(_loot_instance)
	#marco ocupado
	_grid_set_space(_grid_pos, _loot_held.get_loot_size(), true)


func _loot_upgrade(_loot : LootBag):
	_loot.upgrade()

func _loot_remove(_loot_bag : LootBag):
	loot_in_bag.erase(_loot_bag)
	_grid_set_space(_loot_bag.get_grid_position(), _loot_bag.get_loot_size(), false)
	_loot_bag.queue_free()

func _loot_is_in_position(_mouse_position : Vector2, _grid_pos : Vector2) -> LootBag:
	var _loot_in_mouse = _loot_is_in_global_position(_mouse_position)
	if _loot_in_mouse:
		return _loot_in_mouse
	elif _grid_dict.get(_grid_pos):
		return _loot_is_in_global_position(_grid_coordinates_to_global(_grid_pos))
	else:
		return null

func _loot_is_in_global_position(_global_position : Vector2) -> LootBag:
	for _loot_bag in loot_in_bag:
		if _loot_bag.get_global_rect().has_point(_global_position):
			return _loot_bag
	return null

#func _reparent(_child: Node): #SERIA SPAWN LOOT O ALGO ASI
#	if _child.get_parent() != self:
#		var _old_parent = _child.get_parent()
#		_old_parent.remove_child(_child)
#		add_child(_child)

func _grid_set_space(_grid_position : Vector2, _loot_size : Vector2, _state : bool):
	for _i in range(_grid_position.x, _grid_position.x + _loot_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _loot_size.y):
			_grid_dict[ Vector2(_i, _j) ] = _state

func _grid_find_space_available(_grid_position : Vector2, _loot_size : Vector2i) -> Vector2:
	var _final_pos = Vector2(-1,-1)
	#algorithm assumes initial position is free
	if _grid_dict.get(Vector2(_grid_position.x, _grid_position.y)):
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
	if _grid_dict.get(Vector2(_grid_position.x, _grid_position.y)):
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
	var _loot_size = _loot_held.get_loot_size() * CELL_SIZE
	
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

func _grid_coordinates_to_global(_grid_position : Vector2) -> Vector2:
	var _grid_local_pos = _grid_coordinates_to_local(_grid_position)
	return get_global_rect().position + _grid_origin_position + _grid_local_pos

class Loot_Holder:
	var offset : Vector2
	var _loot : Loot
	var _original_grid_pos : Vector2
	
	func _init():
		_empty_values()
	
	func get_loot() -> Loot:
		return _loot
	
	func get_loot_type() -> Loot.LOOT_TYPES:
		return _loot.type
	
	func get_loot_tier() -> int:
		return _loot.tier
	
	func get_loot_size() -> Vector2:
		return _loot.get_size()
	
	func get_grid_position() -> Vector2:
		return _original_grid_pos
	
	func release():
		_loot.free()
		_empty_values()
	
	func grab(_loot_ref : Loot, _offset : Vector2, _pos : Vector2):
		_loot = Loot.new(_loot_ref.type, _loot_ref.tier)
		offset = _offset
		_original_grid_pos = _pos

	func is_held():
		return _loot != null
	
	func is_from_crate():
		return _original_grid_pos == Vector2(-1,-1)

	func _empty_values():
		_loot = null
		offset = Vector2.ZERO
		_original_grid_pos = Vector2(-1,-1)
	
	func _destroy():
		_loot.free()

