extends ParallaxBackground

#3 layered BG
@onready var far = $FarBG
@onready var mid = $MidBG
@onready var close = $CloseBG

@export var speed_walk = 15
@export var speed_run = 40
var speed = 0

func _ready():
	speed = -speed_walk

#scroll BG
func _process(delta):
	#each BG has its own scrolling speed
	far.motion_offset.x += speed * delta
	mid.motion_offset.x += speed * delta * 4
	close.motion_offset.x += speed * delta * 8
	
#disables process calls
func stop_bg():
	set_process(false)
	
func inverse_bg():
	set_process(true)
	speed = speed_run
