extends Control

var curr_artifact

func _ready():
	LootDB.save_loot(generate_loot()) #DEBUGGGING. MUST CHANGE
	update_lootcount()

func current_menu():
	self.visible=true

func leave_menu():
	self.visible=false
	return true


func _on_revelar_left_button_up():
	var firstq = LootDB.get_firstelementloot()
	if firstq == null:
		#no hay loot
		return
	$TextureLoot.texture = load(LootDB.ARTIFACTS[firstq[0]][firstq[1]])
	var reward_artifact = ArtifactDB.loot_table(firstq[0],firstq[1])
	$TextureArtifact.texture = load(ArtifactDB.ARTIFACTS[reward_artifact]["asset"])
	$Panel/ArtifactName.text = ArtifactDB.ARTIFACTS[reward_artifact]["name"]
	update_lootcount()
	reveal_state()
	curr_artifact = reward_artifact

func _on_butt_add_inv_button_up():
	ArtifactDB.inventory.append(curr_artifact)
	curr_artifact = null
	initial_state()
	print(ArtifactDB.inventory)
	
	
func initial_state():
	$TextureLoot.visible = false
	$TextureArrow.visible = false
	$TextureArtifact.visible = false
	$Panel.visible = false
	$RevelarLeft.disabled = false
	$ButtAddInv.visible = false
	
func reveal_state():
	$TextureLoot.visible = true
	$TextureArrow.visible = true
	$TextureArtifact.visible = true
	$Panel.visible = true
	$RevelarLeft.disabled = true
	$ButtAddInv.visible = true
	
func update_lootcount():
	$RevelarLeft/TotalLoot.text = "x" + str(LootDB.get_nloot())
	
	
#debug purposes
func generate_loot():
	var loot = {
		"sword" : {1:1,2:1,4:1},
		"armor" : {1:1,2:2},
		"potato" : {1:4,2:2,3:1}
	}
	return loot
