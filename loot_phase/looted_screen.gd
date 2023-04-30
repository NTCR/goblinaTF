extends Node

const LOOT_REWARD = preload("res://loot_phase/loot_reward/loot_reward.tscn")

@export var next_scene : PackedScene
@export_category("Components:")
@export var grid_box : GridContainer


func _ready():
	var _loot = LootDB.load_loot()
	var _loot_types = _loot.keys()
	for _type in _loot_types:
		for _tier in range(1,LootDB.MAX_TIER):
			if _loot[_type].has(_tier):
				var _reward = LOOT_REWARD.instantiate()
				_reward.apply_texture(LootDB.get_loot_bag(_type)[_tier])
				_reward.apply_count(_loot[_type][_tier])
				grid_box.add_child(_reward)


func _on_butt_shop_up():
	get_tree().change_scene_to_file(next_scene.resource_path)
