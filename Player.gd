extends Area2D

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _collision_shape = $CollisionShape2D
@onready var _loot_timer = $LootTimer


signal looted(loot_type)

func _ready():
	_animated_sprite.play("merge_walk")


func _on_body_entered(body):
	if body.has_meta("type"):
		_animated_sprite.play("merge_loot")
		emit_signal("looted",body.get_meta("type"))
		body.queue_free()
		_loot_timer.start()


func _on_loot_timer_timeout():
	_animated_sprite.play("merge_walk")
