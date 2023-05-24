class_name LootBag
extends TextureRect

var grid_position : Vector2
var loot_contained : Loot

func configure_loot(_loot_info : Loot):
	loot_contained = Loot.new()
	loot_contained.copy(_loot_info)

func set_grid_pos(_grid_pos : Vector2):
	grid_position = _grid_pos

func get_loot_size() -> Vector2:
	return loot_contained.size_cells

func get_loot_tier() -> int:
	return loot_contained.tier

func upgrade():
	loot_contained.tier += 1
	if loot_contained.tier > 4: #MAX_TIER
		print("ERROR TRIED TO UPGRADE OVER MAX TIER")

func _exit_tree():
	loot_contained.free()
