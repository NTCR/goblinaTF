class_name LootBag
extends TextureRect

const TIER_COLORS : Array[Color] = [
	Color8(101,101,101), 
	Color8(53,113,25), 
	Color8(16,27,113), 
	Color8(98,16,113),
	Color8(209,109,17)
]
var grid_position : Vector2
var _loot_contained : Loot

func setup(_loot : Loot, _grid_pos : Vector2):
	_loot_contained = Loot.new(_loot.type, _loot.tier)
	#configure imagen (assets y fondo)
	texture = load(_loot.get_texture_path())
	size = Bag.CELL_SIZE * get_loot_size()
	$TierColor.size = size
	$TierColor.color = TIER_COLORS[_loot_contained.tier - 1]
	grid_position = _grid_pos

func get_loot() -> Loot:
	return _loot_contained

func get_loot_size() -> Vector2:
	return _loot_contained.get_size()

func get_loot_tier() -> int:
	return _loot_contained.tier

func get_loot_type() -> Loot.LOOT_TYPES:
	return _loot_contained.type

func get_grid_position() -> Vector2:
	return grid_position

func set_grid_position(_pos : Vector2):
	grid_position = _pos

func upgrade():
	_loot_contained.tier += 1
	if _loot_contained.tier > 5: #MAX_TIER
		print("ERROR TRIED TO UPGRADE OVER MAX TIER")
	$TierColor.color = TIER_COLORS[_loot_contained.tier - 1]

func can_merge_or_swap(_loot_held : Loot):
	pass

func _exit_tree():
	_loot_contained.free()
