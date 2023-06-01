extends HBoxContainer
#not modular

@export_category("Icons:")
@export var h1 : TextureRect
@export var h2 : TextureRect
@export var sh : TextureRect

func lose_hp(_curr_hp : int):
	match(_curr_hp):
		1:
			h2.visible = false
		0:
			h1.visible = false

func gain_shield():
	sh.visible = true

func lose_shield():
	sh.visible = false
