extends Node

enum TYPES {SWORD,ARMOR,POTATO}
const LOOT_IN_BAG_PATH = "res://loot_phase/loot/"
const LOOT_PATH = "res://loot_phase/loot_base/"
const MAX_TIER = 4

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
	TYPES["ARMOR"] : LOOT_PATH + "armor.png",
	TYPES["POTATO"] : LOOT_PATH + "potato.png",
}
#usually would init in ready
var _loot = { 
	TYPES["SWORD"]: {
		1: 0,
		2: 0,
		3: 0,
		4: 0,
	},
	TYPES["ARMOR"]: {
		1: 0,
		2: 0,
		3: 0,
		4: 0,
	},
	TYPES["POTATO"]: {
		1: 0,
		2: 0,
		3: 0,
		4: 0,
	},
}

# Get loot asset used in gameworld
func get_loot_gameworld(_type):
	if TYPES[_type] in LOOT:
		return LOOT[ TYPES[_type] ]
	print("error in get_loot")
	return null

# Get loot asset used in loot bag
func get_loot_bag(_loot_type, _loot_tier):
	if TYPES[_loot_type] in LOOT_BAG:
		return LOOT_BAG[ TYPES[_loot_type] ][_loot_tier]
	print("error in get_lot_bag")
	return null

#Get a random type
func get_random_type():
	return TYPES.keys()[randi() % TYPES.size()]

# Add loot element to loot count
func add_to_loot(_type,_tier):
	if TYPES[_type] in _loot and _tier <= MAX_TIER: #care _tier can not be 0 or negative
		_loot[ TYPES[_type] ][_tier] += 1

func get_loot_occurrences(_type,_tier):
	return _loot[ TYPES[_type] ][_tier]

# Get loot size (not loot structure size)
func get_loot_size():
	var total_loot = 0
	for _type in _loot.keys():
		for _tier in _loot[_type].keys():
			total_loot += _loot[_type][_tier]
	return total_loot

# Pop first element in loot (not only access)
func get_loot_first_element():
	for _type in TYPES:
		for _tier in _loot[ TYPES[_type] ]:
			if _loot[ TYPES[_type] ][_tier] > 0:
				_loot[ TYPES[_type] ][_tier] -= 1
				return [_type,_tier]
	return null
