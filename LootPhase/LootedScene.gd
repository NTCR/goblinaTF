extends Node

const loot_reward = preload("res://LootPhase/loot/LootReward.tscn")

@export var grid_box : GridContainer
@export var next_scene : PackedScene

func _ready():
	var loot = LootDB.load_loot()
	var loot_types = loot.keys()
	for type in loot_types:
		for tier in range(1,LootDB.MAX_TIER):
			if loot[type].has(tier):
				var reward = loot_reward.instantiate()
				reward.apply_texture(LootDB.get_artifact(type)[tier])
				reward.apply_count(loot[type][tier])
				grid_box.add_child(reward)


func _on_butt_shop_up():
	get_tree().change_scene_to_file(next_scene.resource_path)
