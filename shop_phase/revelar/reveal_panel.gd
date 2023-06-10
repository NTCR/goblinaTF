extends Control

signal panel_closed

@export_category("Components:")
@export var group_empty : Control
@export var group_success : Control
@export var transition : AnimationPlayer

func _ready():
	transition.play("open_reveal")

func setup_panel(_a : Artifact):
	if _a:
		group_success.visible = true
		$Success/ArtifactName.text = _a.name
		var _sprite = Sprite2D.new()
		_sprite.texture = load(_a.get_texture_path())
		_sprite.position = $Success/ArtifactBox.position + $Success/ArtifactBox.size/2
		_sprite.scale = Vector2(0.25,0.25)
		group_success.add_child(_sprite)
	else:
		group_empty.visible = true

func close_panel():
	panel_closed.emit()
	transition.play("close_reveal")
