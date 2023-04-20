extends Node

const ICON_PATH = "res://icons/"
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
	"sword" : "res://LootPhase/loot/sword.png",
	"armor" : "res://LootPhase/loot/armor.png",
	"potato" : "res://LootPhase/loot/potato.png",
	"error" : ICON_PATH + "error.png",
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
	
func print_loot(): #debug purposes
	print(loot)


