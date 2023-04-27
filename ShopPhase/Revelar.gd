extends Control

func _ready():
	update_lootcount()

func current_menu():
	self.visible=true

func leave_menu():
	self.visible=false
	return true

func _on_revelar_left_button_up():
	var firstq = LootDB.get_firstelementloot() #missleading name
	if firstq == null:
		#no hay loot
		return
	$TextureLoot.texture = load(LootDB.ARTIFACTS[firstq[0]][firstq[1]])
	var reward_artifact = ArtifactDB.loot_table(firstq[0],firstq[1])
	$TextureArtifact.texture = load(ArtifactDB.ARTIFACTS[reward_artifact]["asset"])
	$Panel/ArtifactName.text = ArtifactDB.ARTIFACTS[reward_artifact]["name"]
	update_lootcount()
	reveal_state()
	ArtifactDB.discover_artifact(reward_artifact)
	ArtifactDB.inventory.append(reward_artifact)

func _on_butt_continue_up():
	initial_state()
	
func initial_state():
	$TextureLoot.visible = false
	$TextureArrow.visible = false
	$TextureArtifact.visible = false
	$Panel.visible = false
	$RevelarLeft.disabled = false
	$ButtContinue.visible = false
	
func reveal_state():
	$TextureLoot.visible = true
	$TextureArrow.visible = true
	$TextureArtifact.visible = true
	$Panel.visible = true
	$RevelarLeft.disabled = true
	$ButtContinue.visible = true
	
func update_lootcount():
	$RevelarLeft/TotalLoot.text = "x" + str(LootDB.get_nloot())

