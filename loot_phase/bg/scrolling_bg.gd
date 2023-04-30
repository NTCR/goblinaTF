extends ParallaxBackground

#3 layered BG
@export_category("Layers")
@export var far : ParallaxLayer
@export var mid : ParallaxLayer
@export var close : ParallaxLayer
@export_category("Speed settings")
@export var speed_walk = 15
@export var speed_run = 40

var _speed = 0

func _ready():
	_speed = -speed_walk #bg moves backwards

#scroll BG
func _process(_delta):
	#each BG has its own scrolling speed
	far.motion_offset.x += _speed * _delta
	mid.motion_offset.x += _speed * _delta * 4
	close.motion_offset.x += _speed * _delta * 8

# Disables process calls
func stop_bg():
	set_process(false)

# Reverses moving direction
func inverse_bg():
	set_process(true)
	_speed = speed_run
