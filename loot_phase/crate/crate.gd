class_name Crate
extends Sprite2D

const HIT_PARTICLES = preload("res://loot_phase/effects/crate_destroy/particle_wood.tscn")

signal crate_interacted(_crate_ref)
signal crate_hit(_crate_ref)
#signal phase_ended
@export_category("Configuration:")
@export var crate_type : Loot.LOOT_TYPES
@export_category("Components:")
@export var _hit_area : Area2D
@export var _mouse_area : Area2D
var _loot : Loot
@onready var _mouse_rect : Rect2 = _mouse_area.get_child(0).get_shape().get_rect()

func _ready():
	_loot = Loot.new(crate_type) #init loot var

func _exit_tree():
	_loot.free() #get rid of loot object

func _input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT \
			and _event.pressed and _mouse_rect.has_point(to_local(_event.position)):
		#notify gameworld
		crate_interacted.emit(self)

func get_type() -> Loot.LOOT_TYPES:
	return crate_type

#called by gameworld
func move_towards_player(_speed : Vector2):
	position -= _speed

func crate_looted():
	#disable hit just in case
	_hit_area.set_deferred("disabled",true)
	queue_free()

func _on_area_2d_body_entered(_body):
	_crate_hit_player()

func _crate_hit_player():
	#notify gameworld
	crate_hit.emit(self)
	#disable hit (avoid trigger repetition)
	_hit_area.set_deferred("disabled",true)
	#spawn effect
	var _effect = HIT_PARTICLES.instantiate()
	_effect.position = position
	get_tree().current_scene.add_child(_effect)
	queue_free()




