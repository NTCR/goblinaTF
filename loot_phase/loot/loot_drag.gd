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

func loot_drag(_texture_path : String, _size : Vector2, _offset : Vector2):
	create_drag(_texture_path, _size, _offset)
	flip_h = true

func release_drag():
	set_process_input(false)
	queue_free()
