extends TextureRect

signal patience_ran_out()

@export var bar_indicator : ProgressBar

var _progress : int = 0

func increase_bar(_v : int):
	_progress += _v
	bar_indicator.value = _progress
	if _progress >= 100:
		patience_ran_out.emit()
