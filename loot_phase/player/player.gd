extends StaticBody2D

@export_category("Components:")
@export var animated_sprite : AnimatedSprite2D
@export var stun_animation : AnimatedSprite2D

func _ready():
	animated_sprite.play("idle")

func idle():
	animated_sprite.play("idle")

func walk():
	animated_sprite.play("walk")

func run():
	animated_sprite.play("run")

func hit():
	animated_sprite.play("hit")

func recover():
	animated_sprite.play("recover")
	stun_animation.stop()
	stun_animation.visible = false

func flip_horizontal():
	animated_sprite.flip_h = true


func _on_animated_sprite_2d_animation_finished():
	match(animated_sprite.animation):
		"recover" : 
			animated_sprite.play("walk")
		"hit":
			stun_animation.visible = true
			stun_animation.play()
