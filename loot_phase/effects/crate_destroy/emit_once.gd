extends CPUParticles2D

@onready var _timer = $Timer

func _ready():
	emitting = true
	_timer.wait_time = lifetime
	_timer.start()

func _on_timer_timeout():
	queue_free()
