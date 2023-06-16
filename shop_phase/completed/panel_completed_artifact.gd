extends CanvasLayer

signal game_completed()

@export_category("Components:")
@export var transitions : AnimationPlayer
@export var artifact_box : TextureRect
@export var artifact_enchant : Label
@export var charm_container : HBoxContainer
var _artifact : Artifact
var _is_game_completed : bool = false

func _ready():
	transitions.play("open_panel")

func setup_panel(_a : Artifact):
	_artifact = _a
	artifact_box.setup_box(_artifact)
	artifact_enchant.text = '"' + _artifact.enchant + '"'
	for _charm in _artifact.charms_complete:
		var _texture_rect = TextureRect.new()
		_texture_rect.texture = load(Charm.get_icon_normal(_charm))
		_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var _desired_size = Vector2(90,90)
		_texture_rect.set_custom_minimum_size(_desired_size)
		charm_container.add_child(_texture_rect)
	_is_game_completed = Database.progress_is_gamecompleted()
	if _is_game_completed:
		$Control/CompeltedLabel.visible = true
	else:
		$Control/InfoLabel.visible = true

func _on_butt_ok_pressed():
	if _is_game_completed:
		game_completed.emit()
	transitions.play("close_panel")
