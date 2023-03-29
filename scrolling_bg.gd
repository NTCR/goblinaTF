extends ParallaxBackground

@onready var far = $FarBG
@onready var mid = $MidBG
@onready var close = $CloseBG
var speed = -15

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	far.motion_offset.x += speed * delta
	mid.motion_offset.x += speed * delta * 4
	close.motion_offset.x += speed * delta * 8




func _on_player_looted(extra_arg_0):
	pass # Replace with function body.
