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

@export var transition : AnimationPlayer
@export var spawnpoint_crate : Marker2D

func _ready():
	transition.play("enter_storage")
	var _l = Loot.new(Loot.LOOT_TYPES.WIDE,2)
	Database.loot_add(_l)

func _reveal_phase():
	if Database.loot_size() > 0:
		var _l = Database.loot_pop()
		var _crate_instance = CRATES[_l.type].instantiate()
		_crate_instance.position = spawnpoint_crate.position + CRATE_SPAWN_OFFSET[_l.type]
		_crate_instance.connect("crate_opened", Callable(self, "_on_crate_opened"))
		_crate_instance.setup_tier(_l.tier)
		add_child(_crate_instance)
	else:
		pass
		#go tasar

func _on_crate_opened():
	print("I WORK")
	#decidir que artefacto se consigue
	#generar panel
