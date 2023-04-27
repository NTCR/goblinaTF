extends Node

const ARTIFACT_PATH = "res://ShopPhase/ArtifactImages/"
const CHARMICONS_PATH = "res://ShopPhase/IconosEncanto/"
const TYPES = ["sword","armor","potato"]
var curr_gold = 0
var inventory = [] #string array, codename para cada artefacto

var LIBRO_PROGRESS = {}

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
		"asset" : ARTIFACT_PATH + "corrupto.png",
		"unlocked" : "\"Una armadura maldita.\""
	},
	"vladimir" : {
		"name" : "Vladimir",
		"desc" : "Blabla sangre",
		"charm" : ["sword","blood"],
		"properties" : [],
		"type" : TYPES[0],
		"asset" : ARTIFACT_PATH + "fire.png",
		"unlocked" : "\"Una espada con sed de sangre.\""
	},
	"rockstar" : {
		"name" : "Rock Star",
		"desc" : "Highway to hell I guess",
		"charm" : ["potato","modern"],
		"properties" : [],
		"type" : TYPES[2],
		"asset" : ARTIFACT_PATH + "moderna.png",
		"unlocked" : "\"Una patata cosmopolita.\""
	},
	"carlemany" : {
		"name" : "Carlemany",
		"desc" : "El gran Carlemany mon pare blabla",
		"charm" : ["armor","patriotic"],
		"properties" : ["modern"],
		"type" : TYPES[1],
		"asset" : ARTIFACT_PATH + "patria.png",
		"unlocked" : "\"Armadura de una nacion olvidada\""
	},
	"donatello" : {
		"name" : "Donatello",
		"desc" : "Ninja turtles!",
		"charm" : ["sword","poison"],
		"properties" : ["cursed"],
		"type" : TYPES[0],
		"asset" : ARTIFACT_PATH + "poison.png",
		"unlocked" : "\"Una espada envenenada.\""
	},
	"sauron" : {
		"name" : "Sauron",
		"desc" : "BEHOLD",
		"charm" : ["sight","infinity"],
		"properties" : ["potato","cursed","blood"],
		"type" : TYPES[2],
		"asset" : ARTIFACT_PATH + "potato.png",
		"unlocked" : "\"Algo te observa a ti y mas alla\""
	}
}

func _ready():
	#setup progress dict
	for artifact_id in ARTIFACTS.keys():
		LIBRO_PROGRESS[artifact_id] = {"discovered":false}
		for charm in ARTIFACTS[artifact_id]["charm"]:
			LIBRO_PROGRESS[artifact_id][charm] = false

func get_cardicon(charm_id):
	if charm_id in CHARMS:
		var output = CHARMICONS_PATH + "icon_" + charm_id + ".png"
		return output
	else:
		return "res://ShopPhase/IconosEncanto/UNKOWN.png"

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

func discover_artifact(artifact_id):
	LIBRO_PROGRESS[artifact_id]["discovered"] = true
	
func discover_artifactcharm(artifact_id, charm_id):
	LIBRO_PROGRESS[artifact_id][charm_id] = true

func is_artifactdiscovered(artifact_id):
	return LIBRO_PROGRESS[artifact_id]["discovered"]
	
func is_artifactcharmdiscovered(artifact_id, charm_id):
	return LIBRO_PROGRESS[artifact_id][charm_id]

func is_artifactcomplete(artifact_id):
	for _charm in LIBRO_PROGRESS[artifact_id].keys(): #key "discovered" always true here
		if !LIBRO_PROGRESS[artifact_id][_charm]:
			return false
	return true
	
