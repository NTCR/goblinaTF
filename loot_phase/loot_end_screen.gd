extends Node

const LOOT_REWARD = preload("res://loot_phase/loot_reward/loot_reward.tscn")

@export_file var shop_scene
@export_category("Components:")
@export var grid_box : GridContainer


func _ready():
	for _type in LootDB.TYPES:
		for _tier in range(1,LootDB.MAX_TIER+1):
			var _occurrences = LootDB.get_loot_occurrences(_type,_tier)
			if _occurrences > 0:
				var _reward = LOOT_REWARD.instantiate()
				_reward.apply_texture(LootDB.get_loot_bag(_type,_tier))
				_reward.apply_count(_occurrences)
				grid_box.add_child(_reward)

func _on_butt_shop_up():
	get_tree().change_scene_to_file(shop_scene)
