extends ParallaxBackground

#3 layered BG
@export_category("Layers")
@export var _clouds : ParallaxLayer
@export var _mountains : ParallaxLayer
@export var _road : ParallaxLayer
@export var _grass : ParallaxLayer
@export_category("Speed settings")
@export var speed = -3

#scroll BG
func _physics_process(_delta):
	#20 tope
	_clouds.motion_offset.x += speed 
	_mountains.motion_offset.x += speed
	_road.motion_offset.x += speed
	_grass.motion_offset.x += speed

# Disables process calls
func stop_bg():
	set_process(false)

# Reverses moving direction
func inverse_bg():
	set_process(true)
	speed *= -1
