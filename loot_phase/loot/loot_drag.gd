class_name LootDrag
extends DragPreview

signal loot_released()

func _process(_delta):
	global_position = get_global_mouse_position() - _mouse_offset

func _input(_event):
	if _event is InputEventMouseButton \
			and _event.button_index == MOUSE_BUTTON_LEFT \
			and not _event.pressed:
		#libera artifact held
		loot_released.emit()
		queue_free()

func loot_drag_bag(_bag_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2, _grid_pos : Vector2):
	_bag_ref.on_loot_grab_from_bag(_loot,_offset,_grid_pos)
	_setup(_bag_ref, _loot, _size, _offset)

func loot_drag_crate(_bag_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2, _crate_ref : Crate):
	_bag_ref.on_loot_grab_from_crate(_loot,_offset,_crate_ref)
	_setup(_bag_ref, _loot, _size, _offset)

func _setup(_bag_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2):
	#debug
	if not _bag_ref:
		print("ERROR LOOT DRAG: NO BARG REF")
		return
	connect("loot_released", Callable(_bag_ref,"_on_loot_released"))
	var _texture_path = _loot.get_texture_path()
	create_drag(_texture_path, _size, _offset)
	flip_h = true

func _on_crate_hit():
	queue_free()
