extends Node

const MAX_PITY : int = 4
const ARTIFACTS_CSV_FILE = "res://database/artifacts.csv"
const LOOTTABLE_CSV_FILE = "res://database/loottable.csv"

var game_artifacts : Dictionary #dictionary with key:artifact name - value:artifact resource
var game_loottable : Dictionary #dictionary with key:tier - value: array float probabilities
var loot : Array[Loot]
var gold : int = 0
var inventory : Array[Artifact]
var progress : Dictionary
var pity : int = 0

func _ready():
	_load_artifacts_from_csv()
	_load_loottable_from_csv()
	_setup_progress()

func _load_artifacts_from_csv():
	var _file = FileAccess.open(ARTIFACTS_CSV_FILE, FileAccess.READ)
	while !_file.eof_reached():
		var _csv_line = Array(_file.get_csv_line(";"))
		game_artifacts[_csv_line[6]] = Artifact.new()
		var _artifact : Artifact = game_artifacts[_csv_line[6]]
		_artifact.name = _csv_line[0]
		_artifact.description = _csv_line[1]
		_artifact.enchant = _csv_line[2]
		_artifact.rarity = _csv_line[3]
		for _charm_str in _csv_line[4].split(","):
			var _charm = Charm.CHARMS[_charm_str]
			_artifact.charms_complete.append(_charm)
		if _csv_line[5]:
			for _charm_str in _csv_line[5].split(","):
				var _charm = Charm.CHARMS[_charm_str]
				_artifact.charms_valid.append(_charm)
		_artifact.file_name = _csv_line[6]
	_file.close()

func _load_loottable_from_csv():
	var _file = FileAccess.open(LOOTTABLE_CSV_FILE, FileAccess.READ)
	while !_file.eof_reached():
		var _csv_line = Array(_file.get_csv_line(";"))
		var _key = int(_csv_line[0])
		game_loottable[_key] = []
		for _i in range(1,_csv_line.size()):
			var _probability = float(_csv_line[_i])
			game_loottable[_key].append(_probability)
	_file.close()

func _setup_progress():
	for _key in game_artifacts:
		progress[_key] = ArtifactProgress.new()

#LOOT RELATED
func loot_add(_l : Loot):
	#var _n = Loot.new(_l.type, _l.tier)
	loot.append(_l)

func loot_pop() -> Loot:
	return loot.pop_front()

func loot_size() -> int:
	return loot.size()

#LOOTTABLE RELATED
func draw_artifact(_t : int) -> Artifact:
	var _rng = randf_range(0, 100)
	var _prob_array : Array[float] = game_loottable[_t]
	var _prob_stack = 0
	var _rarity : int = 0
	for _i in range(0,_prob_array.size()):
		_prob_stack += _prob_array[_i]
		if _rng<_prob_stack or _prob_stack == 100:
			_rarity = _i
			_i = _prob_array.size()
	return _get_drawn_artifact(_rarity)

func _get_drawn_artifact(_r : int) -> Artifact:
	if pity == MAX_PITY:
		#buscare de _r para arriba el k no haya completado
		pass
	elif _r == 0:
		return null
	else:
		var _artifact_of_t :Array[Artifact] = []
		for _key in game_artifacts:
			var _artifact : Artifact = game_artifacts[_key]
			if _artifact.rarity == _r-1:
				_artifact_of_t.append(_artifact)
		var _drawn_artifact : Artifact = _artifact_of_t[randi() % _artifact_of_t.size()]
		var _artifact_progress : ArtifactProgress = progress[_drawn_artifact.file_name]
		if _artifact_progress.has_been_completed():
			pity += 1
		if not _artifact_progress.is_discovered():
			_artifact_progress.has_been_discovered()
		return _drawn_artifact

#GOLD RELATED
func gold_total():
	return gold

func gold_gained(_i : int):
	gold += _i

func gold_spend_try(_i : int) -> bool:
	if gold < _i:
		return false
	gold -= _i
	return true

#INVENTORY RELATED
func inventory_add_artifact(_artifact : Artifact):
	inventory.append(_artifact)

func inventory_erase_artifact(_artifact : Artifact):
	#MAY NEED SAFE CHECK
	inventory.erase(_artifact)

func inventory_size():
	return inventory.size()

func inventory_get_at(_index : int):
	if _index not in range(0,inventory.size()):
		return null
	return inventory[_index]

#PROGRESS RELATED
func progress_artifact_discovered(_artifact : Artifact):
	var _progress_entry : ArtifactProgress = progress[_artifact.file_name]
	_progress_entry.has_been_discovered()

func progress_charm_succeeded(_artifact : Artifact, _charm : Charm.CHARMS):
	var _progress_entry : ArtifactProgress = progress[_artifact.file_name]
	if _progress_entry.charm_succeeded(_charm):
		_progress_check_artifact_completed(_artifact, _progress_entry)
	
func progress_charm_failed(_artifact : Artifact, _charm : Charm.CHARMS):
	var _progress_entry : ArtifactProgress = progress[_artifact.file_name]
	_progress_entry.charm_failed(_charm)

func progress_is_gamecompleted() -> bool:
	for _key in progress:
		var _progress_entry : ArtifactProgress = progress[_key]
		if not _progress_entry.is_completed():
			return false
	return true

func _progress_check_artifact_completed(_artifact : Artifact, _progress_entry : ArtifactProgress):
	var _complete = true
	for _charm in _artifact.charms_complete:
		_complete &= _progress_entry.is_charm_found(_charm)
	if _complete:
		_progress_entry.has_been_completed()

class ArtifactProgress:
	var _discovered : bool
	var _completed : bool
	var _charms_succes : Array[Charm.CHARMS]
	var _charms_failed : Array[Charm.CHARMS]
	
	func _init():
		_discovered = false
		_completed = false
		_charms_succes = []
		_charms_failed = []
	
	func has_been_discovered():
		_discovered = true
	
	func has_been_completed():
		_completed = true
	
	func is_discovered() -> bool:
		return _discovered
	
	func is_completed() -> bool:
		return _completed
	
	func is_charm_found(_c : Charm.CHARMS) -> bool:
		return _c in _charms_succes
	
	func charm_succeeded(_c : Charm.CHARMS) -> bool:
		if _c not in _charms_succes:
			_charms_succes.append(_c)
			return true
		return false
	
	func charm_failed(_c : Charm.CHARMS):
		if _c not in _charms_failed:
			_charms_failed.append(_c)
