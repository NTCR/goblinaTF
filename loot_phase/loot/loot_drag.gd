class_name LootDrag
extends DragPreview

signal loot_released(_crate_ref)

var _from_crate : Crate = null

func _process(_delta):
	global_position = get_global_mouse_position() - _mouse_offset

func _input(_event):
	if _event is InputEventMouseButton \
			and _event.button_index == MOUSE_BUTTON_LEFT \
			and not _event.pressed:
		#libera artifact held
		loot_released.emit(_from_crate)
		queue_free()

func loot_drag_bag(_bag_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2, _grid_pos : Vector2):
	_setup(_bag_ref, _loot, _size, _offset, _grid_pos)

func loot_drag_crate(_bag_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2, _crate_ref : Crate):
	_from_crate = _crate_ref
	_setup(_bag_ref, _loot, _size, _offset)

func _setup(_bag_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2, _grid_pos : Vector2 = Vector2(-1,-1)):
	if not _bag_ref:
		print("CONFIGURA CRATE")
		return
	connect("loot_released", Callable(_bag_ref,"_on_loot_released"))
	_bag_ref.on_loot_grab(_loot,_offset,_grid_pos)
	var _texture_path = _loot.get_texture_path()
	create_drag(_texture_path, _size, _offset)
	flip_h = true

func _on_crate_hit():
	queue_free()
