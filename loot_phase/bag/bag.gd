extends Control

const LOOT_BAG : Resource = preload("res://loot_phase/loot_bag.tscn")
const LOOT_TEXTURES = {
	1 : "res://loot_phase/loot/crate_common.png",
	2 : "res://loot_phase/loot/crate_uncommon.png",
	3 : "res://loot_phase/loot/crate_unique.png",
	4 : "res://loot_phase/loot/crate_epic.png"
	}
const CELL_SIZE = 144
const N_COLUMNS = 5
const N_ROWS = 4
var _grid = {} #2d array. key [x,y] value bool occupied
@onready var _grid_origin_position : Vector2 = $BagGrid.position.round()
@onready var _grid_end_position : Vector2 = $BagGrid.size
@onready var _loot_held : Loot_Holder = Loot_Holder.new()
@onready var _loot_in_bag : Array[LootBag]

func _ready():
	for _x in range(N_COLUMNS):
		for _y in range(N_ROWS):
			_grid[ Vector2(_x,_y) ] = false

func _process(delta):
	var _mouse_global_position = get_global_mouse_position()
	if _loot_held.is_held() and get_global_rect().has_point(_mouse_global_position):
		var _loot_in_mouse = _is_pos_on_loot(_mouse_global_position)
		var _grid_pos = _grid_drop_coordinates(_mouse_global_position)
		var _loot_info : Loot = _loot_held.loot
		#if on loot -> mark loot if can merge or swap
		if _loot_in_mouse:
			$Preview.position = _grid_coordinates_to_local(_loot_in_mouse.grid_position) + $BagGrid.position
			$Preview.size = _loot_in_mouse.loot_contained.size_cells * CELL_SIZE
			$Preview.visible = true
		#if slot valid -> mark slot candidate
		#if empty - size held and preview pos
		elif _grid_is_space_available(_grid_pos, _loot_info.size_cells):
			$Preview.position = _grid_coordinates_to_local(_grid_pos) + $BagGrid.position
			$Preview.size = _loot_info.size_cells * CELL_SIZE
			$Preview.visible = true
		#if occupied - size current artifact and its pos
		#if none -> INVALID
		else:
			$Preview.visible = false
	else:
		$Preview.visible = false

func _exit_tree():
	_loot_held.free()

func _input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		if get_global_rect().has_point(_event.global_position):
			if _event.pressed:
			#grab
				#NO OFFSET?
				#var _pos_improved_offset = _event.global_position #+ Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
				var _grid_pos = _grid_calculate_coordinates(_event.global_position)
				pass
			elif _loot_held.is_held(): #mouse realeased and loot held

			#drop
				#mouse on loot
				#A.merge
				#B.swap
				#mouse on slot
				#A.free slot
				var _grid_pos = _grid_drop_coordinates(_event.global_position)
				var _loot_info : Loot = _loot_held.loot
				var _candidate_pos = _grid_find_space_available(_grid_pos, _loot_info.size_cells)
				if _grid_is_space_available(_candidate_pos):
					#genero loot bag
					var _loot_instance : LootBag = LOOT_BAG.instantiate()
					_loot_instance.texture = load(LOOT_TEXTURES[_loot_info.tier])
					_loot_instance.size = _loot_info.size_cells * CELL_SIZE
					_loot_instance.configure_loot(_loot_info) #CHECK LATER
					_loot_instance.set_grid_pos(_candidate_pos)
					_loot_instance.position = _grid_coordinates_to_local(_candidate_pos)
					_bag_add_loot(_loot_instance)
					#marco ocupado
					_grid_set_space(_grid_pos, _loot_info.size_cells, true)
				#B.try to fit
				

				print(_grid_pos)
		if not _event.pressed and _loot_held.is_held():
			#reinicio artifact held
			_release_loot()

func _release_loot():
	#gestion si loot in bag
	if not _loot_held.is_from_crate():
		print("loot from bag")
	_loot_held.release()

#func _can_drop_data(_at_position, _data):#check if is loot_bag artifact?
#	var _preview_position = _at_position + _data.preview_offset()
#	var _grid_pos = _calculate_grid_coordinates(_preview_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)) #makes interaction smoother
#	#check if can be merged
#
#	#check if space available 
#	var _loot_size = _data.loot_size()
#	if _is_grid_space_available(_grid_pos, _loot_size):
#		$Preview.set_preview_position(_grid_pos * CELL_SIZE)
#		$Preview.set_loot_size(_loot_size)
#		$Preview.queue_redraw()
#		return true
#	else:
#		return true
#
#func _drop_data(_at_position, _data):
#	var _preview_position = _at_position + _data.preview_offset()
#	var _grid_pos = _calculate_grid_coordinates(_preview_position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2))
#	#position loot
#	_reparent(_data)
#	_data.position = _grid_pos * CELL_SIZE
#	#update grid
#	_set_grid_space(_grid_pos, _data.loot_size(), _data)

func _grid_set_space(_grid_position : Vector2, _loot_size : Vector2, _state : bool):
	for _i in range(_grid_position.x, _grid_position.x + _loot_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _loot_size.y):
			_grid[ Vector2(_i, _j) ] = _state

func _grid_find_space_available(_grid_position : Vector2, _loot_size : Vector2) -> Vector2:
	var _final_pos = Vector2(-1,-1)
	if _grid[ Vector2(_grid_position.x, _grid_position.y) ]:
		return _final_pos
	#ha de tener en cuenta direccion objeto
		#diagonal grid
		#forma pieza
	var _direction = _loot_size.x - _loot_size.y
	if _direction > 0:
		if _grid_position.x + _loot_size.x > N_COLUMNS or _grid_position.x - _loot_size.x < 0:
			return Vector(-1,-1)
		for _x in range(_grid_position.x,_loot_size.x):
			if _grid[ Vector2(_x, _grid_position.y) ]:
				return Vector(-1,-1)
		for _x in range(_loot_size.x,_grid_position.x - _loot_size.x, -1):
			if _grid[ Vector2(_x, _grid_position.y) ]:
				return Vector(-1,-1)
		return _grid_position
	elif _direction < 0:
		pass
	else:
		pass


	#dict safeguard
	if _grid_position.x + _loot_size.x > N_COLUMNS or _grid_position.y + _loot_size.y > N_ROWS:
		return false
	#dict access
	for _i in range(_grid_position.x, _grid_position.x + _loot_size.x):
		for _j in range(_grid_position.y, _grid_position.y + _loot_size.y):
			if _grid[ Vector2(_i, _j) ]:
				return false
	return true

func _grid_test_space_available(_grid_candidate : Vector2, _loot_size : Vector2, _direction : int):
	pass

func fulanito(_grid_candidate : Vector2, _loot_size : Vector2, _direction : Vector2):
	match(_direction):

func _grid_is_space_available(_grid_position : Vector2) -> bool:
	return _grid_position != Vector2(-1,-1)

func _grid_calculate_coordinates(_global_position : Vector2) -> Vector2:
	var _local_position = _global_position - get_global_rect().position
	var _snapd_position = _local_position.clamp(_grid_origin_position, _grid_end_position)
	var _grid_position = _snapd_position - _grid_origin_position
	return (_grid_position / CELL_SIZE).floor()

func _grid_drop_coordinates(_global_position : Vector2) -> Vector2: #only if loot held
	var _pos_improved_offset = _global_position - _loot_held.offset \
						+ Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	return _grid_calculate_coordinates(_pos_improved_offset)

func _grid_coordinates_to_local(_grid_position : Vector2) -> Vector2:
	return _grid_position * CELL_SIZE

#func _calculate_grid_size(_size : Vector2) -> Vector2:
#	return (_size / CELL_SIZE).ceil()

#func _reparent(_child: Node): #SERIA SPAWN LOOT O ALGO ASI
#	if _child.get_parent() != self:
#		var _old_parent = _child.get_parent()
#		_old_parent.remove_child(_child)
#		add_child(_child)

#MAY CHANGE NAME ETC
func _bag_add_loot(_loot_node : Node):
	$LootContainer.add_child(_loot_node)
	_loot_in_bag.append(_loot_node)

func _is_pos_on_loot(_global_position : Vector2) -> LootBag:
	for _loot in _loot_in_bag:
		if _loot.get_global_rect().has_point(_global_position) and _loot.visible:
			return _loot
	return null

func _on_crate_looted(_crate_loot : Loot, _mouse_offset : Vector2):
	_loot_held.grab(_crate_loot,_mouse_offset)

class Loot_Holder:
	var loot : Loot
	var offset : Vector2
	var original_pos : Vector2
	
	func _init(_loot : Loot = null, _offset : Vector2 = Vector2.ZERO, _pos : Vector2 = Vector2(-1,-1)):
		if _loot:
			loot = Loot.new()
			loot.copy(_loot)
		else:
			loot = null
		offset = _offset
		original_pos = _pos
	
	func release():
		loot.free()
		loot = null
		offset = Vector2.ZERO
		original_pos = Vector2(-1,-1)
	
	func grab(_loot : Loot, _offset : Vector2, _pos : Vector2 = Vector2(-1,-1)):
		loot = Loot.new()
		loot.copy(_loot)
		offset = _offset
		original_pos = _pos

	func is_held():
		return loot != null
	
	func is_from_crate():
		return original_pos == Vector2(-1,-1)

