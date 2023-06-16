extends Node

const SELL_PANEL = preload("res://shop_phase/sell/sell_panel.tscn")
const COMPLETED_PANEL = preload("res://shop_phase/completed/panel_completed_artifact.tscn")

@export_file var storage_scene
@export_file var to_loot_scene
@export_file var end_scene
@export var transitions : AnimationPlayer
@export var patience_bar : TextureRect
@export var reaction_indicator : ReactionIndicator

var _sell_panel = null
var _merchant_left := false

func _ready():
	if TransitionManager.transition_from_shop:
		transitions.play("to_sell")
	else:
		transitions.play("to_storage")

func go_storage():
	TransitionManager.transition_from_shop = true
	get_tree().change_scene_to_file(storage_scene)

func go_loot():
	get_tree().change_scene_to_file(to_loot_scene)

func go_endscene():
	get_tree().change_scene_to_file(end_scene)

func begin_sell():
	#spawn panel
	var _panel_instance = SELL_PANEL.instantiate()
	_panel_instance.position = Vector2(736,64)
	_panel_instance.connect("panel_closed", Callable(self, "_on_sell_closed"))
	_panel_instance.connect("begin_main", Callable(self, "on_main_begin"))
	_panel_instance.connect("charm_was_complete", Callable(self, "_on_charm_complete"))
	_panel_instance.connect("charm_was_valid", Callable(self, "_on_charm_valid"))
	_panel_instance.connect("charm_was_invalid", Callable(self, "_on_charm_invalid"))
	_panel_instance.connect("charm_returned", Callable(self, "on_charm_return"))
	_panel_instance.connect("artifact_sold", Callable(self, "on_artifact_sold"))
	_panel_instance.connect("artifact_completed", Callable(self, "on_artifact_completed"))
	_sell_panel = _panel_instance
	$UI.add_child(_panel_instance)
	patience_bar.visible = true
	reaction_indicator.visible = true

func on_main_begin():
	reaction_indicator.on_main()

func _on_charm_complete():
	reaction_indicator.on_perfect()

func _on_charm_valid():
	reaction_indicator.on_valid()

func _on_charm_invalid(_cost : int):
	reaction_indicator.on_invalid()
	patience_bar.increase_bar(_cost)

func on_charm_return():
	reaction_indicator.on_return()

func on_artifact_sold():
	reaction_indicator.on_sell()

func on_artifact_completed(_a : Artifact):
	var _panel_instance = COMPLETED_PANEL.instantiate()
	_panel_instance.setup_panel(_a)
	_panel_instance.connect("game_completed",Callable(self,"on_game_completed"))
	add_child(_panel_instance)

func on_game_completed():
	SoundtrackManager.all_completed()
	transitions.play("game_completed")

func _on_patiencer_bar_patience_ran_out():
	#merchant leaves etc
	reaction_indicator.on_patience_ran_out()
	_sell_panel.merchant_is_leaving()
	_merchant_left = true
	transitions.play("merchant_leave")

func allow_leave():
	if _sell_panel:
		_sell_panel.can_leave()

func _on_sell_closed():
	_sell_panel = null
	#verificaria si se ha ido o no merchant
	if not _merchant_left:
		reaction_indicator.on_leave()
		transitions.play("merchant_leave")
	transitions.queue("to_loot")
