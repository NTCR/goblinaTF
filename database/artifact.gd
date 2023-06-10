extends Resource
class_name Artifact

const ARTIFACT_PATH = "res://shop_phase/artifacts/"

enum RARITIES {
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

var name : String
var description : String
var enchant : String
var rarity : RARITIES
var charms_complete : Array[Charm.CHARMS]
var charms_valid : Array[Charm.CHARMS]
var file_name : String

func get_texture_path() -> String:
	var _s = ARTIFACT_PATH + file_name + ".png"
	return _s

func _to_string():
	var _format : String
	var _s : String
	_s += "Name: %s, Description: %s, Enchant: %s Rarity: %s"
	_format += _s % [name,description,enchant,rarity]
	return _format
