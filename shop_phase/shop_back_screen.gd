extends Node

const CRATES : Array[Resource] = [
	preload("res://shop_phase/crate/crate2p2_reveal.tscn"),
	preload("res://shop_phase/crate/crate1p3_reveal.tscn"),
	preload("res://shop_phase/crate/crate3p1_reveal.tscn")
]
const CRATE_SPAWN_OFFSET : Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0,-32),
	Vector2(-24,0),
]
const REVEAL_PANEL = preload("res://shop_phase/reveal/reveal_panel.tscn")

@export var transition : AnimationPlayer
@export var player : Player
@export var spawnpoint_crate : Marker2D

func _ready():
	transition.play("enter_storage")
	var _l = Loot.new(Loot.LOOT_TYPES.SQUARE,2)
	Database.loot_add(_l)
	_l.tier = 4
	Database.loot_add(_l)
	_l.tier = 1
	Database.loot_add(_l)
	_l.type = Loot.LOOT_TYPES.TALL
	Database.loot_add(_l)
	_l.tier = 3
	Database.loot_add(_l)
	_l.tier = 5
	Database.loot_add(_l)
	_l.type = Loot.LOOT_TYPES.WIDE
	_l.tier = 2
	Database.loot_add(_l)

func _reveal_phase():
	if Database.loot_size() > 0:
		var _l = Database.loot_pop()
		var _crate_instance = CRATES[_l.type].instantiate()
		_crate_instance.position = spawnpoint_crate.position + CRATE_SPAWN_OFFSET[_l.type]
		_crate_instance.connect("crate_opened", Callable(self, "_on_crate_opened"))
		_crate_instance.setup_tier(_l.tier)
		add_child(_crate_instance)
		_l.free()
	else:
		transition.play("to_tasar")

func _tasar_phase():
	print("voy a tasar")

func _on_crate_opened(_t : int):
	var _drawn_artifact : Artifact = Database.draw_artifact(_t)
	var _panel_instance = REVEAL_PANEL.instantiate()
	_panel_instance.setup_panel(_drawn_artifact)
	_panel_instance.position = Vector2(768,152)
	_panel_instance.connect("panel_closed", Callable(self, "_on_panel_closed"))
	$UI.add_child(_panel_instance)
	player.look_right()

func _on_panel_closed(_a : Artifact):
	player.look_left()
	Database.inventory_add_artifact(_a)
	_reveal_phase()
