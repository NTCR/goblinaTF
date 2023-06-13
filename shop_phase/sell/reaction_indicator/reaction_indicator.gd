class_name ReactionIndicator
extends AnimatedSprite2D

var _queue_next := false
var _next_in_queue : String = ""

func _ready():
	play("hi")

func on_main():
	play("waiting")

func on_invalid():
	play("invalid")
	_queue_animation("waiting")

func on_valid():
	play("valid")
	_queue_animation("waiting")

func on_perfect():
	play("perfect")
	_queue_animation("waiting")

func on_return():
	play("confused")
	_queue_animation("waiting")

func on_sell():
	_queue_animation("happy")

func on_patience_ran_out():
	_froce_queue_quit("angry")

func on_leave():
	play("bye")

func _queue_animation(_next_animation : String):
	_queue_next = true
	_next_in_queue = _next_animation

func _froce_queue_quit(_next_animation : String):
	stop()
	_queue_next = false
	play(_next_animation)

func _on_animation_finished():
	if _queue_next:
		play(_next_in_queue)
		_queue_next = false
