extends Node

const ARTIFACT_PATH = "res://ShopPhase/ArtifactImages/"
const CHARMICONS_PATH = "res://ShopPhase/IconosEncanto/"
const TYPES = ["sword","armor","potato"]
var curr_gold = 0
var inventory = [] #string array, codename para cada artefacto

const CHARMS = [ #no se si lo usare
	"armor",
	"cursed",
	"sword",
	"blood",
	"potato",
	"modern",
	"patriotic",
	"poison",
	"sight",
	"infinity"
]

const ARTIFACTS = {
	"sobremaleficio" : {
		"name" : "Sobremaleficio",
		"desc" : "Blabla maldiciones",
		"charm" : ["armor","cursed"],
		"properties" : ["poison"],
		"type" : TYPES[1],
		"asset" : ARTIFACT_PATH + "corrupto.png"
	},
	"vladimir" : {
		"name" : "Vladimir",
		"desc" : "Blabla sangre",
		"charm" : ["sword","blood"],
		"properties" : [],
		"type" : TYPES[0],
		"asset" : ARTIFACT_PATH + "fire.png"
	},
	"rockstar" : {
		"name" : "Rock Star",
		"desc" : "Highway to hell I guess",
		"charm" : ["potato","modern"],
		"properties" : [],
		"type" : TYPES[2],
		"asset" : ARTIFACT_PATH + "moderna.png"
	},
	"carlemany" : {
		"name" : "Carlemany",
		"desc" : "El gran Carlemany mon pare blabla",
		"charm" : ["armor","patriotic"],
		"properties" : ["modern"],
		"type" : TYPES[1],
		"asset" : ARTIFACT_PATH + "patria.png"
	},
	"donatello" : {
		"name" : "Donatello",
		"desc" : "Ninja turtles!",
		"charm" : ["sword","poison"],
		"properties" : ["cursed"],
		"type" : TYPES[0],
		"asset" : ARTIFACT_PATH + "poison.png"
	},
	"sauron" : {
		"name" : "Sauron",
		"desc" : "BEHOLD",
		"charm" : ["sight","infinity"],
		"properties" : ["potato","cursed","blood"],
		"type" : TYPES[2],
		"asset" : ARTIFACT_PATH + "potato.png"
	}
}

func get_cardicon(charm_id):
	if charm_id in CHARMS:
		var output = CHARMICONS_PATH + "icon_" + charm_id + ".png"
		return output
	else:
		return "res://LootPhase/icons/error.png"

func loot_table(type,tier): #prototype purposes
	match(type):
		TYPES[0]:
			if tier > 2:
				return "vladimir"
			else:
				return "donatello"
		TYPES[1]:
			if tier > 2:
				return "sobremaleficio"
			else:
				return "carlemany"
		TYPES[2]:
			if tier > 2:
				return "sauron"
			else:
				return "rockstar"
