class_name Loot
extends Node

var size_cells : Vector2
var tier : int

func _init(_size : Vector2 = Vector2.ZERO, _tier : int = 0):
	size_cells = _size
	tier = _tier

func copy(_loot : Loot):
	size_cells = _loot.size_cells
	tier = _loot.tier

#debug
func swap_size(_size : Vector2):
	size_cells = _size
