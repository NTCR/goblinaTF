extends Node2D

@export_category("Components:")
@export var animated_sprite : AnimatedSprite2D

#animation cycling script

func _ready():
	animated_sprite.play("rest")
	
func play_alert():
	animated_sprite.play("alert")

func play_chase():
	animated_sprite.play("chase")
