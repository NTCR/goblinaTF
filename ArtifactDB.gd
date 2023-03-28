extends Node

const ICON_PATH = "res://icons/"
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

#get artifact if in dictionary, otherwise retrieve error asset
func get_artifact(artifact_id):
	if artifact_id in ARTIFACTS:
		return ARTIFACTS[artifact_id]
	else:
		return ARTIFACTS["error"]
