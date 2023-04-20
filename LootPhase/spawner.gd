extends Node

const loot_base = preload("res://LootPhase/loot/LootBase.tscn")

@onready var spawnPoint = $ItemSpawn

func _on_Spawn_timeout():
	var loot = loot_base.instantiate()
	var type = ArtifactDB.get_random_type()
	loot.set_meta("type", type)
	loot.find_child("Sprite2D").texture = load(ArtifactDB.get_loot(type))
	loot.position = spawnPoint.position
	var velocity = Vector2(randf_range(-350.0, -550.0), 0.0)
	loot.linear_velocity = velocity
	add_child(loot)
