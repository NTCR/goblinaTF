extends Control

signal panel_closed()

@export_category("Components:")
@export var transitions : AnimationPlayer
@onready var buttvol_up = $ButtUpVol
@onready var buttvol_down = $ButtDownVol
@onready var label_vol = $VolLabel

func _ready():
	transitions.play("open_panel")
	var _lvl = SoundtrackManager.get_volume_level()
	label_vol.text = str(_lvl.x) + "/" + str(_lvl.y)

func _input(_event):
	if _event is InputEventMouseButton and not get_global_rect().has_point(_event.global_position):
		transitions.play("close_panel")

func emit_close():
	panel_closed.emit()

func _on_butt_volume_toggled(button_pressed):
	if button_pressed:
		SoundtrackManager.mute()
		buttvol_up.disabled = true
		buttvol_down.disabled = true
	else:
		SoundtrackManager.unmute()
		buttvol_up.disabled = false
		buttvol_down.disabled = false

func _on_butt_up_vol_pressed():
	SoundtrackManager.increase_volume()
	var _lvl = SoundtrackManager.get_volume_level()
	label_vol.text = str(_lvl.x) + "/" + str(_lvl.y)

func _on_butt_down_vol_pressed():
	SoundtrackManager.decrease_volume()
	var _lvl = SoundtrackManager.get_volume_level()
	label_vol.text = str(_lvl.x) + "/" + str(_lvl.y)

func _on_butt_quit_pressed():
	get_tree().quit()


