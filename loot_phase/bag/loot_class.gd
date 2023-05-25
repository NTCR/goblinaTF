class_name Loot
extends Node


enum LOOT_TYPES {SQUARE,TALL,WIDE}
const MAX_TIER = 5
const TYPE_SIZE = {
	LOOT_TYPES.SQUARE : Vector2(2,2),
	LOOT_TYPES.TALL : Vector2(1,3),
	LOOT_TYPES.WIDE : Vector2(3,1),
	}
const LOOT_TEXTURES : Dictionary = {
	Loot.LOOT_TYPES.SQUARE : "res://loot_phase/crate/crate2p2.png",
	Loot.LOOT_TYPES.TALL : "res://loot_phase/crate/crate1p3.png",
	Loot.LOOT_TYPES.WIDE : "res://loot_phase/crate/crate3p1.png"
}

var type : LOOT_TYPES
var tier : int

func _init(_type : LOOT_TYPES, _tier : int = 1):
	type = _type
	tier = _tier
	if _tier > MAX_TIER or _tier <= 0:
		print("ERROR LOOT TIER")

func get_size() -> Vector2:
	return TYPE_SIZE[type]

func get_texture_path() -> String:
	return LOOT_TEXTURES[type]

static func get_random_type():
	return LOOT_TYPES.keys()[randi() % LOOT_TYPES.size()]
