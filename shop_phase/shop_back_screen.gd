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
const TASAR_PANEL = preload("res://shop_phase/tasar_vertical/tasar_panel.tscn")

@export_file var next_scene
@export var transition : AnimationPlayer
@export var player : Player
@export var spawnpoint : Marker2D
var _artifact_spawn : Sprite2D = null

func _ready():
	transition.play("enter_storage")

func _reveal_phase():
	if Database.loot_size() > 0:
		var _l = Database.loot_pop()
		var _crate_instance = CRATES[_l.type].instantiate()
		_crate_instance.position = spawnpoint.position + CRATE_SPAWN_OFFSET[_l.type]
		_crate_instance.connect("crate_opened", Callable(self, "_on_crate_opened"))
		_crate_instance.setup_tier(_l.tier)
		add_child(_crate_instance)
		_l.free()
	else:
		transition.play("to_tasar")

func _on_crate_opened(_t : int):
	var _drawn_artifact : Artifact = Database.draw_artifact(_t)
	var _panel_instance = REVEAL_PANEL.instantiate()
	_panel_instance.setup_panel(_drawn_artifact)
	_panel_instance.position = Vector2(768,152)
	_panel_instance.connect("panel_closed", Callable(self, "_on_reveal_closed"))
	$UI.add_child(_panel_instance)
	player.look_right()

func _on_reveal_closed(_a : Artifact):
	player.look_left()
	Database.inventory_add_artifact(_a)
	_reveal_phase()

func _tasar_phase():
	if Database.gold_total() >= Database.price_tasar(Artifact.RARITIES.UNCOMMON):
		var _panel_instance = TASAR_PANEL.instantiate()
		_panel_instance.position = Vector2(704,192)
		_panel_instance.connect("panel_closed", Callable(self, "_on_tasar_closed"))
		_panel_instance.connect("artifact_selected", Callable(self, "_tasar_curr_artifact"))
		_panel_instance.connect("artifact_deselected", Callable(self, "_tasar_release_artifact"))
		$UI.add_child(_panel_instance)
	else:
		_on_tasar_closed()

func _tasar_curr_artifact(_a : Artifact):
	#spawn artifact
	var _sprite = Sprite2D.new()
	_sprite.texture = load(_a.get_texture_path())
	_sprite.position = spawnpoint.position
	_sprite.scale = Vector2(0.15,0.15)
	add_child(_sprite)
	_artifact_spawn = _sprite

func _tasar_release_artifact():
	#despawn artifact
	_artifact_spawn.queue_free()
	_artifact_spawn = null

func _on_tasar_closed():
	transition.play("to_sell")

func go_front_shop():
	TransitionManager.first_enter_shop = false
	get_tree().change_scene_to_file(next_scene)
