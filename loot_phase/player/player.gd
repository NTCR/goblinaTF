extends Area2D
# Script purpose is mostly animation cycling

# Informs merge system of looting action
signal looted(loot_type)

@export_category("Components:")
@export var animated_sprite : AnimatedSprite2D
@export var loot_timer : Timer

func _ready():
	animated_sprite.play("merge_walk")

func transition_merge():
	animated_sprite.play("spoted")

func enter_runner():
	animated_sprite.play("runner_walk")

func _on_body_entered(body):
	if body.has_meta("type"):
		animated_sprite.play("merge_loot")
		emit_signal("looted",body.get_meta("type"))
		body.queue_free()
		loot_timer.start()

func _on_loot_timer_timeout():
	animated_sprite.play("merge_walk")
