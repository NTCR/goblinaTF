extends ParallaxBackground

@onready var far = $FarBG
@onready var mid = $MidBG
@onready var close = $CloseBG
var speed = -15
var stop = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stop:
		return
	far.motion_offset.x += speed * delta
	mid.motion_offset.x += speed * delta * 4
	close.motion_offset.x += speed * delta * 8
	
#hard coded
func stop_bg():
	stop = true
	
func inverse_bg():
	stop = false
	speed = 40
