class_name Bag
extends Control

signal crate_looted(_crate_ref)

const LOOT_BAG : Resource = preload("res://loot_phase/bag/loot_bag.tscn")
const THROW_PARTICLES = preload("res://loot_phase/effects/particle_wood.tscn")
const BASE_DIRECTIONS = [Vector2(1,0), Vector2(-1,0), Vector2(0,1), Vector2(0,-1)] #algorithm related
const CELL_SIZE = 144 #non adaptive for now
const N_COLUMNS = 5
const N_ROWS = 4
var _grid_dict = {} #accessed with vector2 key, value bool indicates if slot free
@onready var loot_in_bag : Array[LootBag] #keeps references of loot in bag
@onready var _loot_held : Loot_Holder = Loot_Holder.new() #tracks if loot is held + data
#need for calculations
@onready var _grid_origin_position : Vector2 = $BagGrid.position.round()
@onready var _grid_end_position : Vector2 = $BagGrid.size
#preview references. quicker access
@onready var _preview_valid = $BagGrid/PreviewValid
@onready var _preview_invalid = $BagGrid/PreviewInvalid


func _ready():
	#init grid
	for _x in range(N_COLUMNS):
		for _y in range(N_ROWS):
			_grid_dict[ Vector2(_x,_y) ] = false

func _exit_tree():
	_loot_held.free()

func _physics_process(_delta):
	#preview functionality
	var _mouse_global_position = get_global_mouse_position()
	if _loot_held.is_held() and get_global_rect().has_point(_mouse_global_position):
		var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
		var _loot_in_position := _loot_is_in_position(_mouse_global_position, _grid_pos)
		#if loot is in selected slot, want to merge
		if _loot_in_position:
			if _can_merge(_loot_in_position):
				_preview_valid_show(_loot_in_position.get_grid_position(),_loot_in_position.get_loot_size())
			else:
				_preview_invalid_show(_loot_in_position.get_grid_position(),_loot_in_position.get_loot_size())
		#if selected slot is empty, want to insert
		else:
			var _loot_size = _loot_held.get_loot_size()
			var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_size)
			if _grid_is_coordinates_valid(_candidate_pos):
				_preview_valid_show(_candidate_pos,_loot_size)
			else:
				_preview_invalid_show(_grid_pos,_loot_size)
	else:
		_preview_hide()

#----
#PREVIEW INDICATOR CONFIGURATION
func _preview_valid_show(_grid_pos : Vector2, _loot_cell_size : Vector2):
	_preview_valid.position = _grid_coordinates_to_local(_grid_pos)
	_preview_valid.size = _loot_cell_size * CELL_SIZE
	_preview_valid.visible = true
	_preview_invalid.visible = false

func _preview_invalid_show(_grid_pos : Vector2, _loot_cell_size : Vector2):
	var _fixd_pos = _preview_invalid_helper_position(_grid_pos, _loot_cell_size)
	_preview_invalid.position = _grid_coordinates_to_local(_fixd_pos)
	_preview_invalid.size = _loot_cell_size * CELL_SIZE
	_preview_invalid.visible = true
	_preview_valid.visible = false

#helps preview invalid to properly display why interaction is not allowed
func _preview_invalid_helper_position(_grid_pos : Vector2, _loot_cell_size : Vector2) -> Vector2:
	#origin slot is always the one closer to the origin (check algorithm for more info)
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
#----

#GRAB INTERACTION
#gui input restricts input to current rect
func _gui_input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		#DEBUG
		if _loot_held.is_held():
			print("TRYING TO GRAB WHEN LOOT IS HELD")
		var _mouse_global_position = _event.global_position
		var _loot_in_mouse := _loot_is_in_global_position(_mouse_global_position)
		#GRAB
		if _event.pressed and _loot_in_mouse:
			#grab interaction
			_loot_grab(_loot_in_mouse, _mouse_global_position)
			#remove loot
			_loot_remove(_loot_in_mouse)

#on grab, remove loot from bag
func _loot_remove(_loot_bag : LootBag):
	loot_in_bag.erase(_loot_bag)
	_grid_set_space(_loot_bag.get_grid_position(), _loot_bag.get_loot_size(), false)
	_loot_bag.queue_free()

func _loot_grab(_loot_in_mouse : LootBag, _mouse_global_position : Vector2):
	#calculate offset
	#(offset is calculated in bag local position. check _grid_drop_coord for more info)
	var _corner_right_up = _grid_coordinates_to_local(_loot_in_mouse.get_grid_position()) + _grid_origin_position
	var _mouse_local_position = _mouse_global_position - get_global_rect().position
	var _mouse_offset = _mouse_local_position - _corner_right_up
	var _drag_instance = _new_drag(_loot_in_mouse.get_loot(), _mouse_offset)
	_loot_held.grab_from_bag(_loot_in_mouse.get_loot(), _mouse_offset, _loot_in_mouse.get_grid_position(), _drag_instance)

#---
#EXTERNAL CALLS
func on_loot_grab_from_crate(_origin_crate : Crate, _loot_type : Loot.LOOT_TYPES):
	var _temp_loot = Loot.new(_loot_type, 1)
	var _size = CELL_SIZE * _temp_loot.get_size()
	var _offset = _size/2
	
	var _drag_instance = _new_drag(_temp_loot, _offset)
	_loot_held.grab_from_crate(_temp_loot, _offset, _origin_crate, _drag_instance)

func on_crate_destroyed():
	#drop invalid siempre. sea la crate que toca o no
	if _loot_held.is_held():
		_loot_drop_invalid()

func _new_drag(_loot : Loot, _offset : Vector2) -> LootDrag:
	var _texture_path = _loot.get_texture_path()
	var _desired_size = _loot.get_size() * CELL_SIZE
	
	var _drag_instance = LootDrag.new()
	_drag_instance.connect("loot_released", Callable(self, "_on_loot_released"))
	_drag_instance.loot_drag(_texture_path, _desired_size, _offset)
	get_tree().current_scene.find_child("UI").add_child(_drag_instance)
	return _drag_instance

#func on_phase_ended():
	#should be loot return (drop invalid)
#	_loot_held.release()

#DROP INTERACTION
#loot drag release signal
func _on_loot_released():
	var _mouse_global_position = get_global_mouse_position()
	if get_global_rect().has_point(_mouse_global_position):
		#DROP LOOT INTERACTION
		var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
		var _loot_in_position := _loot_is_in_position(_mouse_global_position, _grid_pos)
		if _loot_in_position:
			#a.slot is taken
			if _can_merge(_loot_in_position):
				_loot_upgrade(_loot_in_position)
				_loot_drop_valid()
			else:
				_loot_drop_invalid()
		else:
			var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_held.get_loot_size())
			#b.free slot
			if _grid_is_coordinates_valid(_candidate_pos):
				#add loot to bag
				_loot_add_held(_candidate_pos)
				_loot_drop_valid()
			else:
				_loot_drop_invalid()
	#loot released outside rect
	else:
		_loot_thrown()
#---

#checks if merge operation is valid
func _can_merge(_loot_in_mouse : LootBag) -> bool:
	#same type, same tier and merge wont result in invalid tier
	return _loot_in_mouse.get_loot_type() == _loot_held.get_loot_type() \
			and _loot_in_mouse.get_loot_tier() == _loot_held.get_loot_tier() \
			and _loot_in_mouse.get_loot_tier() < Loot.MAX_TIER +1

#drop operation was succesful. inform gameworld if from crate
func _loot_drop_valid():
	if _loot_held.is_from_crate():
		crate_looted.emit(_loot_held._original_crate)
	_loot_held.release()

#drop operation failed. return held if from bag
func _loot_drop_invalid():
	if not _loot_held.is_from_crate():
		var _grid_pos = _loot_held.get_grid_position()
		_loot_add_held(_grid_pos)
	_loot_held.release()

#loot is drop outside bag rect
func _loot_thrown():
	if not _loot_held.is_from_crate():
		var _effect = THROW_PARTICLES.instantiate()
		_effect.global_position = get_global_mouse_position()
		get_tree().current_scene.find_child("UI").add_child(_effect)
	_loot_held.release()

#upgrade loot bag after merge (reference already retrieved)
func _loot_upgrade(_loot : LootBag):
	_loot.upgrade()

#add loot to bag
func _loot_add_held(_grid_pos : Vector2):
	var _loot_info : Loot = _loot_held.get_loot()
	var _loot_instance : LootBag = LOOT_BAG.instantiate()
	_loot_instance.setup(_loot_info, _grid_pos)
	_loot_instance.position = _grid_coordinates_to_local(_grid_pos)
	$BagGrid/LootContainer.add_child(_loot_instance)
	loot_in_bag.append(_loot_instance)
	#marco ocupado
	_grid_set_space(_grid_pos, _loot_held.get_loot_size(), true)
#---

#functions that support interaction

#find if lootbag is under mouse or in selected slot
func _loot_is_in_position(_mouse_position : Vector2, _grid_pos : Vector2) -> LootBag:
	#check if mouse is over loot
	var _loot_in_mouse = _loot_is_in_global_position(_mouse_position)
	if _loot_in_mouse:
		return _loot_in_mouse
	#mouse is not over loot, but select slot may be
	elif _grid_dict.get(_grid_pos):
		#transform grid pos to global position and check if loot is in there
		return _loot_is_in_global_position(_grid_coordinates_to_global(_grid_pos))
	else:
	#no loot under mouse or in slot
		return null

#find if lootbag is on a global position
func _loot_is_in_global_position(_global_position : Vector2) -> LootBag:
	for _loot_bag in loot_in_bag:
		if _loot_bag.get_global_rect().has_point(_global_position):
			return _loot_bag
	return null

func _grid_set_space(_grid_position : Vector2, _loot_size : Vector2, _state : bool):
	for _i in range(_grid_position.x, _grid_position.x + _loot_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _loot_size.y):
			_grid_dict[ Vector2(_i, _j) ] = _state

func _grid_find_space_available(_grid_position : Vector2, _loot_size : Vector2i) -> Vector2:
	var _final_pos = Vector2(-1,-1)
	#safe check. initial slot should be free
	if _grid_dict.get(Vector2(_grid_position.x, _grid_position.y)):
		return _final_pos
	
	var _jumps_left : Array[int] = [_loot_size.x-1, _loot_size.x-1, _loot_size.y-1, _loot_size.y-1]
	var _min_size : int = _loot_size.x * _loot_size.y
	var _path = _path_recursive_finding(_grid_position, [], [], _jumps_left.duplicate(true), _min_size)
	if _path.size() >= _min_size:
		#valid
		#find origin
		return _path_node_closest_origin(_path)
	else:
		return _final_pos

#_jumps_left must always be size 4
func _path_recursive_finding(_grid_position : Vector2, _visited : Array[Vector2],
		_shortest : Array[Vector2], _jumps_left : Array[int], _min_size : int) -> Array[Vector2]:
	#visitados -> current path
	_visited.append(_grid_position)
	for _cardinal in range(0,_jumps_left.size()):
		if _jumps_left[_cardinal] > 0:
			var _next_position = _grid_position + BASE_DIRECTIONS[_cardinal]
			if _path_node_check_valid(_next_position, _visited):
				_jumps_left[_cardinal] -= 1
				var _candidate_path = _path_recursive_finding(_next_position, _visited.duplicate(true), _shortest.duplicate(true), _jumps_left.duplicate(true), _min_size)
				_shortest = _candidate_path
	#check new path validity
	#current path is valid
	if _visited.size() >= _min_size:
		#current path is better than shortest path found
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

#find anchor slot
func _path_node_closest_origin(_path : Array[Vector2]) -> Vector2:
	var _origin = _path[0]
	for _pos in _path:
		if _origin.length() > _pos.length():
			_origin = _pos
	return _origin

#check if _grid_find_space_available found a valid slot
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
	var _corner_left_up = _local_position - _loot_held.get_offset()
	var _corner_left_down = Vector2(_corner_left_up.x, _corner_left_up.y + _loot_size.y)
	var _corner_right_up = Vector2(_corner_left_up.x + _loot_size.x, _corner_left_up.y)
	var _corner_right_down = _corner_left_up + _loot_size
	#determine anchors -> half a cell is corrected to improve interaction to each corner
	#(takes as reference slot center, and not slots corner
	var _anchor_left_up = _corner_left_up + Vector2(_half_a_cell, _half_a_cell)
	var _anchor_left_down = _corner_left_down + Vector2(_half_a_cell, -_half_a_cell)
	var _anchor_rigt_up = _corner_right_up + Vector2(-_half_a_cell, _half_a_cell)
	var _anchor_right_down = _corner_right_down + Vector2(-_half_a_cell, -_half_a_cell)
	
	#use by default left up anchor
	_local_position = _anchor_left_up
	#grid is split in 4 quadrants. if inside an specific quadrant its anchor is out of bounds, use that anchors position
	var _out_of_boud = _grid_end_position + _grid_origin_position
	var _grid_mid_point_x = _grid_rect.size.x/2 + _grid_origin_position.x
	var _grid_mid_point_y = _grid_rect.size.y/2 + _grid_origin_position.y
	if(_local_position.x >= _grid_mid_point_x):
		if(_local_position.y > _grid_mid_point_y):
			#quadrant lower right
			if _anchor_right_down.x >= _out_of_boud.x or _anchor_right_down.y >= _out_of_boud.y:
				_local_position = _anchor_right_down
		else:
			#quadrant upper right
			if _anchor_rigt_up.x >= _out_of_boud.x or _anchor_rigt_up.y <= _grid_origin_position.y:
				_local_position = _anchor_rigt_up
	else:
		if(_local_position.y > _grid_mid_point_y):
			#quadrant lower left
			if _anchor_left_down.x <= _grid_origin_position.x or _anchor_left_down.y >=_out_of_boud.y:
				_local_position = _anchor_left_down
	#(quadrant upper left is already handled by default)
	
	#position is snaped to the grid, this way it accepts input outside grid but inside bag rect
	var _snapd_position = _local_position.clamp(_grid_origin_position, _grid_end_position)
	#from bag local position to grid local position
	var _baggrid_position = _snapd_position - _grid_origin_position
	return _grid_coordinates_from_local(_baggrid_position)

#convert grid local position to grid position
func _grid_coordinates_to_local(_grid_position : Vector2) -> Vector2:
	return _grid_position * CELL_SIZE

#convert grid position to grid local position
func _grid_coordinates_from_local(_local_position : Vector2) -> Vector2:
	return (_local_position / CELL_SIZE).floor()

#convert grid position to global position
func _grid_coordinates_to_global(_grid_position : Vector2) -> Vector2:
	var _grid_local_pos = _grid_coordinates_to_local(_grid_position)
	return get_global_rect().position + _grid_origin_position + _grid_local_pos

#---
#innerclass LootHolder
class Loot_Holder:
	var _loot : Loot
	var _offset : Vector2
	var _original_grid_pos : Vector2 #if Vector2(-1,-1), loot has no origin position
	var _original_crate : Crate
	var _drag_reference : LootDrag
	
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
		
	func get_offset() -> Vector2:
		return _offset
	
	func get_grid_position() -> Vector2:
		return _original_grid_pos
	
	func get_origin_crate() -> Crate:
		return _original_crate
	
	func get_drag() -> LootDrag:
		return _drag_reference
	
	func release():
		#DEBUG
		if not _loot:
			print("ERROR MULTIPLE RELEASES!!! HELD ALREADY EMPTY")
			return
		_loot.free()
		_drag_reference.release_drag()
		_empty_values()

	func grab_from_bag(_loot_ref : Loot, _in_offset : Vector2, _pos : Vector2, _drag_ref : LootDrag):
		_loot = Loot.new(_loot_ref.type, _loot_ref.tier)
		_offset = _in_offset
		_original_grid_pos = _pos
		_drag_reference = _drag_ref
		
		_original_crate = null

	func grab_from_crate(_loot_ref : Loot, _in_offset : Vector2, _crate_ref : Crate, _drag_ref : LootDrag):
		_loot = Loot.new(_loot_ref.type, _loot_ref.tier)
		_offset = _in_offset
		_original_crate = _crate_ref
		_drag_reference = _drag_ref
		
		_original_grid_pos = Vector2(-1,-1)

	func is_held():
		return _loot != null
	
	func is_from_crate():
		return _original_crate != null

	func _empty_values():
		_loot = null
		_offset = Vector2.ZERO
		_original_grid_pos = Vector2(-1,-1)
		_original_crate = null
		_drag_reference = null
	
	func _destroy():
		if _loot:
			_loot.free()
		if _drag_reference:
			_drag_reference.release_drag()

