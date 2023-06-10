extends Sprite2D

const CLICK_PARTICLES = preload("res://shop_phase/crate/effect/particle_wood_small.tscn")

signal crate_opened

@export_category("Components:")
@export var mouse_area : Area2D
@export var bar : ProgressBar

@onready var _mouse_rect : Rect2 = mouse_area.get_child(0).get_shape().get_rect()
var _progress = 0
var _tier = 1
var _click_needed = 1

func _ready():
	var _box = StyleBoxFlat.new()
	_box.bg_color = LootBag.get_tier_color(_tier)
	bar.add_theme_stylebox_override("fill", _box)
	

func _input(_event):
	if _event is InputEventMouseButton and _event.button_index == MOUSE_BUTTON_LEFT \
			and _event.pressed and _mouse_rect.has_point(to_local(_event.position)):
		#spawn particles at position
		_click_effect(get_global_mouse_position())
		#reduce progress
		_reduce_progress()
		if _progress >= 100:
			_open()

func setup_tier(_t : int):
	_tier = _t
	_click_needed = 3 + _tier #COMMENT PROPERLY

func _click_effect(_pos : Vector2):
	var _effect = CLICK_PARTICLES.instantiate()
	_effect.global_position = _pos
	get_tree().current_scene.add_child(_effect)

func _reduce_progress():
	var _variance = 7
	var _mean = floor(100/_click_needed)
	var _increase = randi_range(_mean-_variance,_mean+_variance)
	_progress += _increase
	bar.value = _progress

func _open():
	set_process_input(false)
	crate_opened.emit()
