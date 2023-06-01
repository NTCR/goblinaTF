extends ParallaxBackground

var _motion : float = 2

func _ready():
	stop()

#scroll BG
func _physics_process(_delta):
	#20 tope
	scroll_offset.x += _motion

# Disables process calls
func stop():
	set_physics_process(false)

func start():
	set_physics_process(true)

func set_motion(_value : float):
	_motion = _value

# Reverses moving direction
func inverse_motion():
	set_process(true)
	_motion *= -1
