class_name LootBag
extends TextureRect

var loot_contained : Loot
var grid_position : Vector2

func configure_loot(_loot_info : Loot):
	loot_contained = Loot.new()
	loot_contained.copy(_loot_info)

func set_grid_pos(_grid_pos : Vector2):
	grid_position = _grid_pos

func _exit_tree():
	loot_contained.free()
