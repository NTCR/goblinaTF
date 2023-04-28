extends Area2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _loot_timer = $LootTimer

#informs merge system of looting
signal looted(loot_type)

#mostly animation cycling

func _ready():
	_animated_sprite.play("merge_walk")

func transition_merge():
	_animated_sprite.play("spoted")

func enter_runner():
	_animated_sprite.play("runner_walk")

func _on_body_entered(body):
	if body.has_meta("type"):
		_animated_sprite.play("merge_loot")
		emit_signal("looted",body.get_meta("type"))
		body.queue_free()
		_loot_timer.start()

func _on_loot_timer_timeout():
	_animated_sprite.play("merge_walk")
