extends Node

@export_category("Components:")
@export var spawnPoint : Marker2D

func _on_Spawn_timeout():
	var _loot = LOOT_BASE.instantiate()
	var _type = LootDB.get_random_type()
	_loot.set_meta("type", _type)
	_loot.find_child("Sprite2D").texture = load(LootDB.get_loot_gameworld(_type))
	_loot.position = spawnPoint.position
	var _velocity = Vector2(randf_range(-350.0, -550.0), 0.0)
	_loot.linear_velocity = _velocity
	add_child(_loot)
