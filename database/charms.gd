extends Resource
class_name Charm

const CHARM_PATH = "res://shop_phase/charms/"
const HOVER_PATH = "res://shop_phase/charms/hover/"
const CLICK_PATH = "res://shop_phase/charms/click/"
const EMPTY_CHARM = "res://shop_phase/charms/empty.png"
const UNDISCOVERED_CHARM = "res://shop_phase/charms/unknown.png"

enum CHARMS{
	GEM, #caro, valioso, tesoro, enjoyado
	FIST, #poder, victoria, fuerza
	CROWN, #realeza, rey o reina
	CENTRAL, #central territory
	NORTH, #viking, north
	HEART, #love, affection
	CLAW, #beast, dragon
	SWORDS, #warrior, war, battle, fight
	MAGE, #mage, west
	HOUSE, #home, lair
	SOUTH, #pirate, south
	QUAVER, #narrate, recite, melody, sound
}

static func get_icon_normal(_c : CHARMS) -> String:
	var _path = CHARM_PATH + str(_c) + ".png"
	return _path

static func get_icon_hover(_c : CHARMS) -> String:
	var _path = HOVER_PATH + str(_c) + ".png"
	return _path

static func get_icon_click(_c : CHARMS) -> String:
	var _path = CLICK_PATH + str(_c) + ".png"
	return _path
