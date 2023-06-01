class_name Crate
extends Sprite2D

const HIT_PARTICLES = preload("res://loot_phase/effects/particle_wood.tscn")

signal crate_looted
signal crate_hit
@export_category("Configuration:")
@export var crate_type : Loot.LOOT_TYPES
@export_category("Components:")
@export var _hit_area : Area2D
@export var _mouse_area : Area2D
var _bag_reference : Bag
var _loot : Loot
@onready var _rect : Rect2 = _mouse_area.get_child(0).get_shape().get_rect()

func _ready():
	_loot = Loot.new(crate_type)

func _input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT:
		if _rect.has_point(to_local(_event.position)) and _event.pressed:
			_create_drag()

func _exit_tree():
	_loot.free()


func setup_bag(_ref : Bag):
	_bag_reference = _ref

func move_towards_player(_speed : Vector2):
	position -= _speed

func crate_has_been_looted():
	#MORE THINGS HAPPEN WHEN CRATE LOOT
	crate_looted.emit()
	#disable hit just in case
	_hit_area.set_deferred("disabled",true)
	queue_free()

func _create_drag():
	var _drag_instance = LootDrag.new()
	var _size = Bag.CELL_SIZE * _loot.get_size()
	var _mouse_offset = _size/2
	_drag_instance.loot_drag_crate(_bag_reference, _loot, _size, _mouse_offset, self)
	connect("crate_hit", Callable(_drag_instance, "_on_crate_hit"))
	get_tree().current_scene.find_child("UI").add_child(_drag_instance)

func _on_area_2d_body_entered(_body):
	_crate_hit_player()

func _crate_hit_player():
	crate_hit.emit()
	_bag_reference.on_crate_destroyed()
	_hit_area.set_deferred("disabled",true)
	var _effect = HIT_PARTICLES.instantiate()
	_effect.position = position
	get_tree().current_scene.add_child(_effect)
	queue_free()
