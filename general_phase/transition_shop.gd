extends Node

@export_file var shop_scene
@export_file var loot_scene
@export_category("Components:")
@export var parallax : ParallaxBackground
@export var transitions : AnimationPlayer

func _ready():
	parallax.set_motion(-6)
	parallax.start()
	if TransitionManager.transition_from_shop:
		transitions.play("to_loot")
		SoundtrackManager.going_loot()
	else:
		transitions.play("to_shop")
		SoundtrackManager.going_shop()

func to_shop_scene():
	get_tree().change_scene_to_file(shop_scene)

func to_loot_scene():
	TransitionManager.transition_from_shop = false
	get_tree().change_scene_to_file(loot_scene)
