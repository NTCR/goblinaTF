extends Node

const ICON_PATH = "res://LootPhase/icons/"
const LOOT_PATH = "res://LootPhase/loot/"
const TYPES = ["sword","armor","potato"]
const MAX_TIER = 4
var loot = {}

#dictionary with loot artifacts
const ARTIFACTS = {
	"sword": {
		1: ICON_PATH + "sword-t1.png",
		2: ICON_PATH + "sword-t2.png",
		3: ICON_PATH + "sword-t3.png",
		4: ICON_PATH + "sword-t4.png",
	},
	"armor": {
		1: ICON_PATH + "armor-t1.png",
		2: ICON_PATH + "armor-t2.png",
		3: ICON_PATH + "armor-t3.png",
		4: ICON_PATH + "armor-t4.png",
	},
	"potato": {
		1: ICON_PATH + "potato-t1.png",
		2: ICON_PATH + "potato-t2.png",
		3: ICON_PATH + "potato-t3.png",
		4: ICON_PATH + "potato-t4.png",
	},
	"error":{
		1: ICON_PATH + "error.png",
	}
}

const LOOT = {
	"sword" : LOOT_PATH + "sword.png",
	"armor" : LOOT_PATH + "armor.png",
	"potato" : LOOT_PATH + "potato.png",
	"error" : ICON_PATH + "error.png", #temp
}

#get artifact if in dictionary, otherwise retrieve error asset
func get_artifact(artifact_id):
	if artifact_id in ARTIFACTS:
		return ARTIFACTS[artifact_id]
	else:
		return ARTIFACTS["error"]#get artifact if in dictionary, otherwise retrieve error asset

func get_loot(loot_id):
	if loot_id in LOOT:
		return LOOT[loot_id]
	else:
		return LOOT["error"]
		
func get_random_type():
	return TYPES[randi() % TYPES.size()]
	
func save_loot(loot_dict):
	loot = loot_dict

func load_loot():
	return loot
	
func get_nloot():
	if loot.is_empty():
		return 0
	var total_loot = 0
	for type in loot.keys():
		for tier in loot[type].keys():
			total_loot += loot[type][tier]
	return total_loot
	
func get_firstelementloot():
	for type in loot:
		for tier in loot[type]:
			if loot[type][tier] > 0:
				loot[type][tier] -= 1
				return [type,tier]
	return null
	
func print_loot(): #debug purposes
	print(loot)


