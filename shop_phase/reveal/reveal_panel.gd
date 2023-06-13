extends Control

signal panel_closed(artifact)

@export_category("Components:")
@export var group_empty : Control
@export var group_success : Control
@export var transition : AnimationPlayer
@export var nameplate : Label
@export var box : TextureRect

var _artifact : Artifact = null

func _ready():
	transition.play("open_reveal")

func setup_panel(_a : Artifact):
	if _a:
		group_success.visible = true
		nameplate.text = _a.name
		var _color = LootBag.TIER_COLORS[_a.rarity+1]
		nameplate.add_theme_color_override("font_color",_color)
		box.setup_box(_a)
		_artifact = _a
	else:
		group_empty.visible = true

func close_panel():
	$Success/ButtAddInv.disabled = true
	$Empty/ButtOK.disabled = true
	panel_closed.emit(_artifact)
	transition.play("close_reveal")
