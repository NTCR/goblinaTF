extends Node

const MAX_VOLUME = 10
const STEP_VOLUME = 3.0

@export var transition : AnimationPlayer
@export var track_merge : AudioStreamPlayer2D
@export var track_shop : AudioStreamPlayer2D
var _curr_track : AudioStreamPlayer2D
var _curr_volume := 0.0
var _volume_level := 6

func _ready():
	_curr_track = track_merge

func mute():
	AudioServer.set_bus_mute(0,true)

func unmute():
	AudioServer.set_bus_mute(0,false)

func get_volume_level() -> Vector2i:
	return Vector2i(_volume_level,MAX_VOLUME)

func increase_volume():
	if _volume_level < MAX_VOLUME:
		_curr_volume += STEP_VOLUME
		_volume_level += 1
		_curr_track.volume_db = _curr_volume

func decrease_volume():
	if _volume_level > 1:
		_curr_volume -= STEP_VOLUME
		_volume_level -= 1
		_curr_track.volume_db = _curr_volume

func going_shop():
	_curr_track = track_shop
	_curr_track.volume_db = _curr_volume
	var _animation = transition.get_animation("from_loot")
	var _indx = _animation.find_track("AudoStreamMerge:volume_db", Animation.TYPE_BEZIER)
	_animation.bezier_track_set_key_value(_indx,0,_curr_volume)
	_animation.bezier_track_set_key_value(_indx,1,-40)
	transition.play("from_loot")

func going_loot():
	_curr_track = track_merge
	_curr_track.volume_db = _curr_volume
	var _animation = transition.get_animation("from_shop")
	var _indx = _animation.find_track("AudioStreamShop:volume_db", Animation.TYPE_BEZIER)
	_animation.bezier_track_set_key_value(_indx,0,_curr_volume)
	_animation.bezier_track_set_key_value(_indx,1,-40)
	transition.play("from_shop")

func all_completed():
	var _animation = transition.get_animation("all_completed")
	var _indx = _animation.find_track("AudioStreamShop:volume_db", Animation.TYPE_BEZIER)
	_animation.bezier_track_set_key_value(_indx,0,_curr_volume)
	_animation.bezier_track_set_key_value(_indx,1,-50)
	transition.play("all_completed")

func end_credits():
	$AudioStreamEnd.volume_db = _curr_volume
	$AudioStreamEnd.play()
