extends Node

const ICON_PATH = "res://icons/"
#dictionary with loot artifacts
const ARTIFACTS = {
	"sword_t1": {
		"icon": ICON_PATH + "sword-t1.png",
		"tier": 1
	},
	"sword_t2": {
		"icon": ICON_PATH + "sword-t2.png",
		"tier": 2
	},
	"sword_t3": {
		"icon": ICON_PATH + "sword-t3.png",
		"tier": 3
	},
	"sword_t4": {
		"icon": ICON_PATH + "sword-t4.png",
		"tier": 4
	},
	"armor_t1": {
		"icon": ICON_PATH + "armor-t1.png",
		"tier": 1
	},
	"armor_t2": {
		"icon": ICON_PATH + "armor-t2.png",
		"tier": 2
	},
	"armor_t3": {
		"icon": ICON_PATH + "armor-t3.png",
		"tier": 3
	},
	"armor_t4": {
		"icon": ICON_PATH + "armor-t4.png",
		"tier": 4
	},
	"potato_t1": {
		"icon": ICON_PATH + "potato-t1.png",
		"tier": 1
	},
	"potato_t2": {
		"icon": ICON_PATH + "potato-t2.png",
		"tier": 2
	},
	"potato_t3": {
		"icon": ICON_PATH + "potato-t3.png",
		"tier": 3
	},
	"potato_t4": {
		"icon": ICON_PATH + "potato-t4.png",
		"tier": 4
	},
	"error":{
		"icon": ICON_PATH + "error.png",
		"tier": 0
	}
}

#get artifact if in dictionary, otherwise retrieve error asset
func get_artifact(artifact_id):
	if artifact_id in ARTIFACTS:
		return ARTIFACTS[artifact_id]
	else:
		return ARTIFACTS["error"]
