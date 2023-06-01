extends Node

const CRATES : Array[Resource] = [
	preload("res://loot_phase/crate/crate2p2.tscn"),
	preload("res://loot_phase/crate/crate1p3.tscn"),
	preload("res://loot_phase/crate/crate3p1.tscn")
]
const CRATE_SPAWN_OFFSET : Array[Vector2] = [
	Vector2(0,-10),
	Vector2(0,-45),
	Vector2(0,10),
]
const INITIAL_HP = 2
const MAX_GEAR = 5
const GEAR_SPEED : Array[Vector2] = [
	Vector2(0,0),
	Vector2(2,0),
	Vector2(3,0),
	Vector2(4,0),
	Vector2(5,0),
	Vector2(7,0),
]
const GEAR_TIMER : Array[float] = [
	15.0,
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
@export var bar_speed : TextureRect
@export var bar_hp : HBoxContainer
@export var clouds : ParallaxBackground
@export var background : ParallaxBackground
@export var foreground : ParallaxBackground
@export var player : StaticBody2D
var _gear : int = 0
var _progress : int = 0
var _hp : int = INITIAL_HP

#on create crate: connect signal, add to group
func _ready():
	#spawn initial crate
	var _initial_crate = _spawn_crate(spawn_initial.position)
	_initial_crate.set_process_input(false)
	spawn_timer.stop()
	clouds.set_motion(-0.5)
	clouds.start()

#some method that manages gear swap
func increase_progress():
	#was idle
	if _gear == 0:
		player.position.x += 2
		if _hp < INITIAL_HP:
			player.recover()
		else:
			player.walk()
		_gear = 1
		_progress = 2
		bar_speed.set_gear(_gear)
		_start_parallax()
		_set_gear_settings()
		#timer revision
		spawn_timer.timeout.emit()
		spawn_timer.start()
	#already playing
	elif _gear < MAX_GEAR:
		bar_speed.increase()
		_progress += 1
		if not _progress % 2:
			player.position.x += 2
			_gear += 1
			_set_gear_settings()
			if _gear < 4:
				player.walk()
			else:
				player.run()
				bar_hp.gain_shield()

func decrease_progress():
	if _gear > 3:
		player.position.x -= 6
		_gear -= 3
		_progress -= 6
		bar_speed.set_gear(_gear)
		_set_gear_settings()
		bar_hp.lose_shield()
	else:
		_gear_stop()

func _gear_stop():
	$Player.position.x = 206
	player.hit()
	_gear = 0
	_progress = 0
	bar_speed.stop_gear()
	spawn_timer.stop()
	_stop_parallax()
	_hp -= 1
	bar_hp.lose_hp(_hp)
	if _hp == 0:
		bag_ref.on_phase_ended()
		get_tree().current_scene.end_phase()

func _set_gear_settings():
	_move_parallax(GEAR_SPEED[_gear].x)
	spawn_timer.set_wait_time(GEAR_TIMER[_gear])

func _physics_process(_delta):
	if _gear > 0:
		get_tree().call_group("crates", "move_towards_player", GEAR_SPEED[_gear])

func _move_parallax(_speed : float):
	background.set_motion(-_speed)
	foreground.set_motion(-_speed)

func _stop_parallax():
	background.stop()
	foreground.stop()

func _start_parallax():
	background.start()
	foreground.start()

func _spawn_crate(_position : Vector2) -> Crate:
	#crate type
	var _type = _probability_crate_type()
	var _crate_instance = CRATES[_type].instantiate()
	_crate_instance.position = _position + CRATE_SPAWN_OFFSET[_type]
	
	_crate_instance.add_to_group("crates")
	_crate_instance.connect("crate_looted", Callable(self, "_on_crate_looted"))
	_crate_instance.connect("crate_hit", Callable(self, "_on_crate_hit"))
	_crate_instance.setup_bag(bag_ref)
	add_child(_crate_instance)
	return _crate_instance

func _probability_crate_type() -> int:
	var _highest_tier = {}
	for _type in Loot.LOOT_TYPES.values():
		_highest_tier[_type] = 0
	for _loot_bag in bag_ref.loot_in_bag:
		var _type = _loot_bag.get_loot_type()
		var _tier = _loot_bag.get_loot_tier()
		if _highest_tier.get(_type) < _tier:
			_highest_tier[_type] = _tier
	#non flexible to tier changes
	var _total_tickets = 0
	for _type in Loot.LOOT_TYPES.values():
		var _tickets
		match _highest_tier.get(_type):
			0:
				_tickets = 33
			1:
				_tickets = 20
			2, 3, 4:
				_tickets = 66
			5:
				_tickets = 20
		_highest_tier[_type] = _tickets
		_total_tickets += _tickets
	var _draw_ticket = randi_range(0,_total_tickets)
	for _type in Loot.LOOT_TYPES.values():
		_total_tickets -= _highest_tier.get(_type)
		if _draw_ticket > _total_tickets:
			return _type
	print("you shouldnt be here")
	return 0

#spawner
func _on_spawn_timer_timeout():
	_spawn_crate(spawn_point.position)

func _on_crate_looted():
	increase_progress()
	#print(get_tree().get_nodes_in_group("crates").size())

func _on_crate_hit():
	decrease_progress()



