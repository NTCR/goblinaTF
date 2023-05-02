extends Control

signal game_over()
const CHARM_CARD = preload("res://shop_phase/drag_and_drop/drag_card.tscn")
@export_category("Components:")
@export var panel_comercio : Panel
@export var panel_drop_artifact : Panel
@export var panel_kick : Panel
@export var panel_merchant : TextureRect
@export var scroll_cards : ScrollContainer
@export var grid_cards : GridContainer
@export var bar_patience : ProgressBar
@export var text_merchant : Label
@export var texture_artifact : TextureRect
@export var context_sold : Control
@export var text_sold : Label
@export var context_failed : Control
@export var text_failed : Label
var _curr_artifact
var _total_cards
var _curr_cards = 0
var _merchant_left = false
@onready var _card_slots = $ComercioPanel/HCDropZone.get_children()

func current_menu():
	visible=true
	
func leave_menu():
	if _merchant_left:
		visible=false
		_merchant_leaves()
		return true
	else:
		if _curr_artifact:
			panel_comercio.visible=false
		else:
			panel_drop_artifact.visible = false
		panel_kick.visible = true
		return false

func _merchant_leaves():
	_merchant_left = true
	panel_merchant.visible = false
	panel_comercio.visible = false
	panel_drop_artifact.visible = false
	panel_kick.visible = false
	bar_patience.visible = false
	$TextNoMerchant.visible = true

#BEGIN PHASE
func _on_drop_panel_begin_phase(_artifact_id):
	panel_drop_artifact.visible = false
	panel_comercio.visible = true
	bar_patience.visible = true
	#artifact is sold regardless outcome
	ArtifactDB.inventory_erase_artifact(_artifact_id)
	_curr_artifact = _artifact_id
	texture_artifact.texture = load(ArtifactDB.ARTIFACTS[_curr_artifact]["asset"])
	_total_cards = ArtifactDB.ARTIFACTS[_curr_artifact]["charm"].size()
	for _i in range(0,_total_cards):
		_card_slots[_i].visible = true
	_merchant_reaction(":0")
	#add cards, right now we add all the cards, so they could all already be there
	#future versions may change (unlock charm)
	for _charm_id in ArtifactDB.CHARMS:
		var _card_instance = CHARM_CARD.instantiate()
		_card_instance.set_charm(_charm_id)
		_card_instance.texture = load(ArtifactDB.get_card_icon(_charm_id))
		grid_cards.add_child(_card_instance)
#2 POSSIBLE END STATES
func _artifact_sold():
	#check if game completed
	if ArtifactDB.is_game_completed():
		emit_signal("game_over")
		return
	#get rid of cards in grid
	for _card in grid_cards.get_children():
		_card.queue_free()
	#make scroll invisible
	scroll_cards.visible = false
	var _revenue = _calculate_revenue(true)
	#add revenue to players gold
	ArtifactDB.gold_gain(_revenue)
	#indicate item is sold and revenue 
	text_sold.text = "CONGRATULATIONS! SOLD FOR" + str(_revenue) + "GOLD"
	context_sold.visible = true

func _patience_runsout():
	var _revenue = _calculate_revenue(false)
	#add revenue to players gold
	ArtifactDB.gold_gain(_revenue)
	#indicate item is sold and revenue
	text_failed.text = "SOLD THE ARTIFACT AT THE LOWEST PRICE, " + str(_revenue) \
			+ " GOLD. BETTER LUCK NEXT TIME"
	scroll_cards.visible = false
	context_failed.visible = true
	_merchant_reaction("BYE!")
	_merchant_left = true

#DURING PHASE
#signal for each card slot, treat all equally
func _on_drop_card_1_card_try(_charm_id):
	_card_try(_charm_id)

func _on_drop_card_2_card_try(_charm_id):
	_card_try(_charm_id)

func _on_drop_card_3_card_try(_charm_id):
	_card_try(_charm_id)

func _on_drop_card_4_card_try(_charm_id):
	_card_try(_charm_id)

func _card_try(_charm_id):
	if ArtifactDB.is_charm_good(_curr_artifact, _charm_id):
		_merchant_reaction(":D")
		#unlock charm
		ArtifactDB.discover_artifact_charm(_curr_artifact,_charm_id)
		_good_card(_charm_id)
	elif ArtifactDB.is_charm_ok(_curr_artifact, _charm_id):
		_merchant_reaction("OK.")
		_good_card(_charm_id)
	else:
		#make card unavailable
		for _card in grid_cards.get_children():
			if _card.get_charm() == _charm_id:
				_card.disable_drag()
				grid_cards.move_child(_card,grid_cards.get_child_count())
		_merchant_reaction("X")
		bar_patience.value += 10
		if bar_patience.value == 100:
			_patience_runsout()

func _good_card(_charm_id):
	for _slot in _card_slots:
		if _slot.visible and _slot.is_free():
			_slot.assign_texture(ArtifactDB.get_card_icon(_charm_id))
			break
	for _card in grid_cards.get_children():
		if _card.get_charm() == _charm_id:
			_card.queue_free()
	_curr_cards += 1
	if _curr_cards == _total_cards:
		_artifact_sold()

func _calculate_revenue(_merchant_stays):
	#depends on loot table etc
	if _merchant_stays:
		return 100
	else:
		return 10

func _merchant_reaction(_text):
	text_merchant.text = _text

func _on_butt_sold_button_up():
	#back to initial phase, not initial state
	panel_drop_artifact.visible = true
	panel_comercio.visible = false
	context_sold.visible = false
	scroll_cards.visible = true
	#clean drop slots
	for _slot in _card_slots:
		_slot.make_free()
		_slot.visible = false
	_reset_vars()
	_merchant_reaction("MORE!")
	
func _reset_vars():
	_curr_artifact = null
	_total_cards = null
	_curr_cards = 0


func _on_butt_stay_up():
	if _curr_artifact:
		panel_comercio.visible= true
	else:
		panel_drop_artifact.visible = true
	panel_kick.visible = false

func _on_butt_failed_button_up():
	_merchant_leaves()

func _on_butt_leave_up():
	_merchant_leaves()
