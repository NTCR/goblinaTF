class_name LootDrag
extends DragPreview

var _bag_reference : Bag

func _process(_delta):
	global_position = get_global_mouse_position() - _mouse_offset

func _input(_event):
	if _event is InputEventMouseButton \
			and _event.button_index == MOUSE_BUTTON_LEFT \
			and not _event.pressed:
		#libera artifact held
		_bag_reference.loot_released()
		queue_free()

func configure_loot_drag(_ref : Bag, _loot : Loot, _size : Vector2, _offset : Vector2, _grid_pos : Vector2 = Vector2(-1,-1)):
	_bag_reference = _ref
	if not _bag_reference:
		print("CONFIGURA CRATE")
	else:
		#avisar a bag new held
		_bag_reference.loot_grab(_loot,_offset,_grid_pos)
	var _texture_path = _loot.get_texture_path()
	create_drag(_texture_path, _size, _offset)
	flip_h = true
