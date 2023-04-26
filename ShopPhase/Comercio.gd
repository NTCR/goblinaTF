extends Control

var curr_artifact
var total_cards
var curr_cards = 0
var merchant_left = false
@onready var cardslots = $ComercioPanel/HCDropZone.get_children()

const card_base = preload("res://ShopPhase/DragCard.tscn")

func current_menu():
	self.visible=true
	
func leave_menu():
	if merchant_left:
		self.visible=false
		merchant_leaves()
		return true
	else:
		if curr_artifact != null:
			$ComercioPanel.visible=false
		else:
			$DropPanel.visible = false
		$KickPanel.visible = true
		return false


#drop panel manda una signal que indica inicio venta
func _on_drop_panel_begin_phase(artifact_id):
	$DropPanel.visible = false
	$ComercioPanel.visible = true
	$PacienciaBar.visible = true
	ArtifactDB.inventory.erase(artifact_id)
	curr_artifact = artifact_id
	$ComercioPanel/TextureArtifact.texture = load(ArtifactDB.ARTIFACTS[curr_artifact]["asset"])
	total_cards = ArtifactDB.ARTIFACTS[curr_artifact]["charm"].size()
	for i in range(0,total_cards):
		cardslots[i].visible = true
	_merchant_reaction(":0")
	#add cards, right now we add all the cards, so they could all already be there
	#future versions may change (unlock charm)
	for charm in ArtifactDB.CHARMS:
		var card_instance = card_base.instantiate()
		card_instance.set_charm(charm)
		card_instance.texture = load(ArtifactDB.get_cardicon(charm))
		$ComercioPanel/ScrollCCards/GridCCards.add_child(card_instance)

func _artifact_sold():
	#get rid of card
	for card in $ComercioPanel/ScrollCCards/GridCCards.get_children():
		card.queue_free()
	#make scroll invisible
	$ComercioPanel/ScrollCCards.visible = false
	var _revenue = _calculate_revenue(true)
	#add revenue to players gold
	ArtifactDB.curr_gold += _revenue
	#indicate item is sold and revenue
	$ComercioPanel/Sold/TextSold.text = "CONGRATULATIONS! SOLD FOR" + str(_revenue) + "GOLD"
	$ComercioPanel/Sold.visible = true
	
func _patience_runsout():
	var _revenue = _calculate_revenue(false)
	#add revenue to players gold
	ArtifactDB.curr_gold += _revenue
	#indicate item is sold and revenue
	$ComercioPanel/Failed/TextFailed.text = "	SOLD THE ARTIFACT AT THE LOWEST PRICE, " + str(_revenue) \
	+ " GOLD. BETTER LUCK NEXT TIME"
	$ComercioPanel/ScrollCCards.visible = false
	$ComercioPanel/Failed.visible = true
	_merchant_reaction("BYE!")
	merchant_left = true

#signal for each card slot, treat all equally
func _on_drop_card_1_card_try(charm_id):
	_card_try(charm_id)


func _on_drop_card_2_card_try(charm_id):
	_card_try(charm_id)


func _on_drop_card_3_card_try(charm_id):
	_card_try(charm_id)


func _on_drop_card_4_card_try(charm_id):
	_card_try(charm_id)


func _card_try(charm_id):
	if charm_id in ArtifactDB.ARTIFACTS[curr_artifact]["charm"]:
		print("YES")
		_merchant_reaction(":D")
		#unlock charm
		_good_card(charm_id)
	elif charm_id in ArtifactDB.ARTIFACTS[curr_artifact]["properties"]:
		_merchant_reaction("OK.")
		print("OK")
		_good_card(charm_id)
	else:
		var _grid = $ComercioPanel/ScrollCCards/GridCCards
		for card in _grid.get_children():
			if card.get_charm() == charm_id:
				card.disable_drag()
				_grid.move_child(card,_grid.get_child_count())
		_merchant_reaction("X")
		$PacienciaBar.value += 10
		if $PacienciaBar.value == 100:
			_patience_runsout()
			
func _good_card(charm_id):
	for slot in cardslots:
		if slot.visible and slot.is_free():
			slot.assign_texture(ArtifactDB.get_cardicon(charm_id))
			break
	var _grid = $ComercioPanel/ScrollCCards/GridCCards
	for card in _grid.get_children():
		if card.get_charm() == charm_id:
			card.queue_free()
	curr_cards += 1
	if curr_cards == total_cards:
		_artifact_sold()
		
func _calculate_revenue(_merchant_stays):
	#depends on loot table etc
	if _merchant_stays:
		return 100
	else:
		return 10

func _merchant_reaction(_text):
	$ComercioLeft/BubbleSpeech/TextInitial.text = _text


func _on_butt_sold_button_up():
	#back to initial phase, not initial state
	$DropPanel.visible = true
	$ComercioPanel.visible = false
	$ComercioPanel/Sold.visible = false
	$ComercioPanel/ScrollCCards.visible = true
	#clean drag
	for slot in cardslots:
		slot.make_free()
		slot.visible = false
	_reset_vars()
	_merchant_reaction("MORE!")
	
func _reset_vars():
	curr_artifact = null
	total_cards = null
	curr_cards = 0


func _on_butt_failed_button_up():
	merchant_leaves()
	
func merchant_leaves():
	merchant_left = true
	$ComercioLeft.visible = false
	$ComercioPanel.visible = false
	$DropPanel.visible = false
	$KickPanel.visible = false
	$PacienciaBar.visible = false
	$TextNoMerchant.visible = true


func _on_butt_stay_up():
	if curr_artifact != null:
		$ComercioPanel.visible= true
	else:
		$DropPanel.visible = true
	$KickPanel.visible = false


func _on_butt_leave_up():
	merchant_leaves()
