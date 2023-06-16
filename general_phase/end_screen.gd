extends Node

@export var parallax : ParallaxBackground
@export var transitions : AnimationPlayer

func _ready():
	parallax.set_motion(-6)
	parallax.start()
	SoundtrackManager.end_credits()
	transitions.play("enter_endscreen")

func credits():
	transitions.play("end_credits")

func quit_game():
	get_tree().quit()
