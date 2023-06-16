extends AnimatedSprite2D

signal slot_ended()

var _desired_charm : Charm.CHARMS

func start_slot(_c : Charm.CHARMS):
	$AnimationPlayer.play("slot")
	speed_scale = 1
	_desired_charm = _c

func _prepare_last_loop():
	connect("frame_changed",Callable(self,"_find_stop"))

func _find_stop():
	if frame == _desired_charm:
		$AnimationPlayer.stop()
		speed_scale = 0
		slot_ended.emit()
		disconnect("frame_changed",Callable(self,"_find_stop"))
