extends Node

const loot_reward = preload("res://LootPhase/loot/LootReward.tscn")

@export var grid_box : GridContainer

func _ready():
	var loot = ArtifactDB.load_loot()
	var loot_types = loot.keys()
	for type in loot_types:
		for tier in range(1,ArtifactDB.MAX_TIER):
			if loot[type].has(tier):
				var reward = loot_reward.instantiate()
				reward.apply_texture(ArtifactDB.get_artifact(type)[tier])
				reward.apply_count(loot[type][tier])
				grid_box.add_child(reward)
