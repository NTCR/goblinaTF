extends Node

@export_file var next_scene
@export var parallax : ParallaxBackground

func _ready():
	parallax.set_motion(4)
	parallax.start()

func _on_butt_new_g_button_up():
	get_tree().change_scene_to_file(next_scene)
