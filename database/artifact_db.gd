extends Node


enum CHARMS {
	ARMOR,
	CURSED,
	SWORD,
	BLOOD,
	POTATO,
	MODERN,
	PATRIOTIC,
	POISON,
	SIGHT,
	INFINITY,
}

const ARTIFACT_PATH = "res://shop_phase/assets/artifacts/"
const CHARM_ICONS_PATH = "res://shop_phase/assets/enchant_icons/"
const TYPES = LootDB.TYPES

const ARTIFACTS = {
	"sobremaleficio" : {
		"name" : "Sobremaleficio",
		"desc" : "Blabla maldiciones",
		"charm" : [ CHARMS["ARMOR"], CHARMS["CURSED"] ],
		"properties" : [ CHARMS["POISON"] ],
		"type" : TYPES["ARMOR"],
		"asset" : ARTIFACT_PATH + "corrupto.png",
		"unlocked" : '"Una armadura maldita."'
	},
	"vladimir" : {
		"name" : "Vladimir",
		"desc" : "Blabla sangre",
		"charm" : [ CHARMS["SWORD"],CHARMS["BLOOD"] ],
		"properties" : [],
		"type" : TYPES["SWORD"],
		"asset" : ARTIFACT_PATH + "fire.png",
		"unlocked" : 'Una espada con sed de sangre."'
	},
	"rockstar" : {
		"name" : "Rock Star",
		"desc" : "Highway to hell I guess",
		"charm" : [ CHARMS["POTATO"], CHARMS["MODERN"] ],
		"properties" : [],
		"type" : TYPES["POTATO"],
		"asset" : ARTIFACT_PATH + "moderna.png",
		"unlocked" : '"Una patata cosmopolita."'
	},
	"carlemany" : {
		"name" : "Carlemany",
		"desc" : "El gran Carlemany mon pare blabla",
		"charm" : [ CHARMS["ARMOR"], CHARMS["PATRIOTIC"] ],
		"properties" : [ CHARMS["MODERN"] ],
		"type" : TYPES["ARMOR"],
		"asset" : ARTIFACT_PATH + "patria.png",
		"unlocked" : '"Armadura de una nacion olvidada"'
	},
	"donatello" : {
		"name" : "Donatello",
		"desc" : "Ninja turtles!",
		"charm" : [ CHARMS["SWORD"], CHARMS["POISON"] ],
		"properties" : [ CHARMS["CURSED"] ],
		"type" : TYPES["SWORD"],
		"asset" : ARTIFACT_PATH + "poison.png",
		"unlocked" : '"Una espada envenenada."'
	},
	"sauron" : {
		"name" : "Sauron",
		"desc" : "BEHOLD",
		"charm" : [ CHARMS["SIGHT"], CHARMS["INFINITY"] ],
		"properties" : [ CHARMS["POTATO"], CHARMS["CURSED"], CHARMS["BLOOD"]],
		"type" : TYPES["POTATO"],
		"asset" : ARTIFACT_PATH + "potato.png",
		"unlocked" : '"Algo te observa desde el más alla."'
	},
}

var _curr_gold : int = 0
var _inventory = [] #string array, codename para cada artefacto
var _book_progress = {}

func _ready():
	#setup progress dict
	for _artifact_id in ARTIFACTS.keys():
		_book_progress[_artifact_id] = {"discovered":false}
		for _charm_code in ARTIFACTS[_artifact_id]["charm"]:
			var _charm_id = CHARMS.keys()[_charm_code]
			_book_progress[_artifact_id][_charm_id] = false

func gold_total():
	return _curr_gold

func gold_gain(_value):
	_curr_gold += _value

func gold_spend(_value):
	if _curr_gold < _value:
		return false
	_curr_gold -= _value
	return true

func inventory_add_artifact(_artifact_id):
	_inventory.append(_artifact_id)

func inventory_erase_artifact(_artifact_id):
	_inventory.erase(_artifact_id)

func inventory_size():
	return _inventory.size()

func inventory_get_at(_index):
	if _index not in range(0,_inventory.size()):
		return null
	return _inventory[_index]

func get_card_icon(_charm_id):
	if _charm_id in CHARMS:
		var _output = CHARM_ICONS_PATH + "icon_" + str(_charm_id).to_lower() + ".png"
		return _output
	else:
		return "res://shop_phase/assets/enchant_icons/UNKNOWN.png"

func loot_table(_type,_tier): #prototype purposes
	match( TYPES[_type] ):
		TYPES["SWORD"]:
			if _tier > 2:
				return "vladimir"
			else:
				return "donatello"
		TYPES["ARMOR"]:
			if _tier > 2:
				return "sobremaleficio"
			else:
				return "carlemany"
		TYPES["POTATO"]:
			if _tier > 2:
				return "sauron"
			else:
				return "rockstar"

func discover_artifact(_artifact_id):
	_book_progress[_artifact_id]["discovered"] = true
	
func discover_artifact_charm(_artifact_id, _charm_id):
	_book_progress[_artifact_id][_charm_id] = true

func is_charm_good(_artifact_id, _charm_id):
	if CHARMS[_charm_id] in ArtifactDB.ARTIFACTS[_artifact_id]["charm"]:
		return true
	else:
		return false

func is_charm_ok(_artifact_id, _charm_id):
	if CHARMS[_charm_id] in ArtifactDB.ARTIFACTS[_artifact_id]["properties"]:
		return true
	else:
		return false

func is_artifact_discovered(_artifact_id):
	return _book_progress[_artifact_id]["discovered"]
	
func is_artifact_charm_discovered(_artifact_id, _charm_id):
	return _book_progress[_artifact_id][_charm_id]

func is_artifact_complete(_artifact_id):
	for _charm in _book_progress[_artifact_id].keys(): #key "discovered" always true here
		if not _book_progress[_artifact_id][_charm]:
			return false
	return true

func is_game_completed():
	for _artifact_id in ARTIFACTS.keys():
		for _charm_code in ARTIFACTS[_artifact_id]["charm"]:
			var _charm_id = CHARMS.keys()[_charm_code]
			if not _book_progress[_artifact_id][_charm_id]:
				return false
	return true
