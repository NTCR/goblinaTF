extends Node

const loot_base = preload("res://loot/LootBase.tscn")

@onready var spawnPoint = $Marker2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_Spawn_timeout():
	var loot = loot_base.instantiate()
	var type = ArtifactDB.get_random_type()
	loot.set_meta("type", type)
	loot.find_child("Sprite2D").texture = load(ArtifactDB.get_loot(type))
	loot.position = spawnPoint.position
	var velocity = Vector2(randf_range(-350.0, -550.0), 0.0)
	loot.linear_velocity = velocity
	get_tree().current_scene.add_child(loot)
