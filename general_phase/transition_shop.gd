extends Node

@export_file var next_scene
@export_category("Components:")
@export var parallax : ParallaxBackground
@export var transitions : AnimationPlayer

func _ready():
	parallax.set_motion(-6)
	parallax.start()
	transitions.play("to_shop")

func to_shop_scene():
	get_tree().change_scene_to_file(next_scene)
