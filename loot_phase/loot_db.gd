extends Node

enum TYPES {SWORD,ARMOR,POTATO}
const LOOT_IN_BAG_PATH = "res://loot_phase/loot/"
const LOOT_PATH = "res://loot_phase/loot_base/"
const MAX_TIER = 4
var _loot = {}
#1key tipo 2key tier value nobtained

#dictionary with loot artifacts
const LOOT_BAG = {
	TYPES["SWORD"]: {
		1: LOOT_IN_BAG_PATH + "sword-t1.png",
		2: LOOT_IN_BAG_PATH + "sword-t2.png",
		3: LOOT_IN_BAG_PATH + "sword-t3.png",
		4: LOOT_IN_BAG_PATH + "sword-t4.png",
	},
	TYPES["ARMOR"]: {
		1: LOOT_IN_BAG_PATH + "armor-t1.png",
		2: LOOT_IN_BAG_PATH + "armor-t2.png",
		3: LOOT_IN_BAG_PATH + "armor-t3.png",
		4: LOOT_IN_BAG_PATH + "armor-t4.png",
	},
	TYPES["POTATO"]: {
		1: LOOT_IN_BAG_PATH + "potato-t1.png",
		2: LOOT_IN_BAG_PATH + "potato-t2.png",
		3: LOOT_IN_BAG_PATH + "potato-t3.png",
		4: LOOT_IN_BAG_PATH + "potato-t4.png",
	},
}

const LOOT = {
	TYPES["SWORD"] : LOOT_PATH + "sword.png",
	TYPES["ARMOR"]: LOOT_PATH + "armor.png",
	TYPES["POTATO"] : LOOT_PATH + "potato.png",
}

# Get loot bag asset
func get_loot_bag(_loot_type):
	if TYPES[_loot_type] in LOOT_BAG:
		return LOOT_BAG[TYPES[_loot_type]]
	print("error in get_lot_bag")
	return null

# Get loot asset
func get_loot(_type):
	if TYPES[_type] in LOOT:
		return LOOT[TYPES[_type]]
	print("error in get_loot")
	return null

#Get a random type
func get_random_type():
	return TYPES.keys()[randi() % TYPES.size()]

# Save given loot structure
func save_loot(_loot_dict):
	_loot = _loot_dict

# Load loot structure
func load_loot():
	return _loot

# Get loot size (not loot structure size)
func get_loot_size():
	if _loot.is_empty():
		return 0
	var total_loot = 0
	for type in TYPES:
		for tier in _loot[type].keys(): #would be better usin max tier
			total_loot += _loot[type][tier]
	return total_loot

# Get first element in loot (not only access)
func get_loot_first_element():
	for type in TYPES:
		for tier in _loot[type]:
			if _loot[type][tier] > 0:
				_loot[type][tier] -= 1
				return [type,tier]
	return null


