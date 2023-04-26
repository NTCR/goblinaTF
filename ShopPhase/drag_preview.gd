extends Sprite2D

func _ready():
	pass
	
func _process(delta):
	global_position = get_global_mouse_position()
	
	if Input.is_action_just_released("inv_grab"):
		queue_free()
