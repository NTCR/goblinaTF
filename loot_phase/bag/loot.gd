extends Control

const CELL_SIZE := 64
const DRAG_PREVIEW := preload("res://loot_phase/bag/loot_preview.tscn")

@export_category("Size:")
@export var cells_x = 0
@export var cells_y = 0
@export_category("Colors:")
@export_color_no_alpha var tier_1
@export_color_no_alpha var tier_2
@export_color_no_alpha var tier_3
@export_color_no_alpha var tier_4
var tier = 1
var _artifact_offset : Vector2

func _ready():
	size = Vector2(cells_x*CELL_SIZE,cells_y*CELL_SIZE)

func _get_drag_data(_at_position):
	_artifact_offset = global_position - get_global_mouse_position()
	var _preview = DRAG_PREVIEW.instantiate()
	_preview.set_color(_get_tier_color(tier))
	_preview.set_cursor_offset(_artifact_offset)
	_preview.set_preview_size(size)
	get_tree().current_scene.add_child(_preview)
	return self

func loot_size() -> Vector2:
	return Vector2(cells_x, cells_y)

func preview_offset() -> Vector2:
	return _artifact_offset

func _get_tier_color(_tier):
	match(_tier):
		1: return tier_1
		2: return tier_2
		3: return tier_3
		4: return tier_4

func _draw():
	draw_rect(Rect2(0,0,cells_x*CELL_SIZE,cells_y*CELL_SIZE), _get_tier_color(tier))
