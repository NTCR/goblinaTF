extends Node

const CRATES : Array[Resource] = [
	preload("res://loot_phase/crate/crate2p2.tscn"),
	preload("res://loot_phase/crate/crate1p3.tscn"),
	preload("res://loot_phase/crate/crate3p1.tscn")
]
const MAX_GEAR = 5
const GEAR_SPEED : Array[Vector2] = [
	Vector2(2,0),
	Vector2(3,0),
	Vector2(4,0),
	Vector2(5,0),
	Vector2(7,0),
]
const GEAR_TIMER : Array[float] = [
	5.0,
	4.0,
	3.0,
	2.0,
	1.5,
]

@export_category("References:")
@export var bag_ref : Bag
@export_category("Components:")
@export var spawn_initial : Marker2D
@export var spawn_point: Marker2D
@export var spawn_timer : Timer
@export var bar : ProgressBar
var gear : int = 0
var _progress = 0 #DEBUG

#on create crate: connect signal, add to group
func _ready():
	#spawn initial crate
	_spawn_crate(spawn_initial.position)

#some method that manages gear swap
func increase_progress():
	if gear == 0:
		gear += 1
		_progress = 20
		bar.value = _progress
		_set_gear_settings()
		spawn_timer.timeout.emit()
		spawn_timer.start()
	elif gear < MAX_GEAR:
		_progress += 10
		bar.value = _progress
		if not _progress % 20:
			gear += 1
			_set_gear_settings()

func decrease_progress():
	if gear > 3:
		gear -= 3
		_progress -= 60
		_set_gear_settings()
	else:
		gear = 0
		_progress = 0
		spawn_timer.stop()

func _set_gear_stop():
	gear = 0
	_progress = 0
	spawn_timer.stop()
	$ScrollingBG.speed = 0

func _set_gear_settings():
	$ScrollingBG.speed = -GEAR_SPEED[gear-1].x
	spawn_timer.set_wait_time(GEAR_TIMER[gear-1])

func _physics_process(_delta):
	if gear > 0:
		get_tree().call_group("crates", "move_towards_player", GEAR_SPEED[gear-1])
		

func _spawn_crate(_position : Vector2):
	var _crate_instance = CRATES[0].instantiate()
	_crate_instance.position = _position
	_crate_instance.add_to_group("crates")
	_crate_instance.connect("crate_looted", Callable(self, "_on_crate_looted"))
	_crate_instance.connect("crate_hit", Callable(self, "_on_crate_hit"))
	_crate_instance.setup_bag(bag_ref)
	add_child(_crate_instance)

#spawner
func _on_spawn_timer_timeout():
	_spawn_crate(spawn_point.position)

func _on_crate_looted():
	increase_progress()

func _on_crate_hit():
	decrease_progress()



