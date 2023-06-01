extends TextureRect

@onready var _bars = $VBoxContainer.get_children()

func _ready():
	_bars.reverse()

#HIDE ALL
func stop_gear():
	for _bar in _bars:
		_bar.visible = false

func set_gear(_gear : int):#no invalid gear protection
	stop_gear()
	var _i = _gear * 2
	for _bar in _bars:
		if _i > 0:
			_bar.visible = true
			_i -= 1
		else:
			_bar.visible = false

#INCREMENT
#el primero no visible pasa a visible
func increase():
	for _bar in _bars:
		if not _bar.visible:
			_bar.visible = true
			return


#DECREMENT
#el ultimo visible pasa a visible
func decrease():
	var _rbars = _bars
	_rbars.reverse()
	for _bar in _rbars:
		if _bar.visible:
			_bar.visible = false
			return
