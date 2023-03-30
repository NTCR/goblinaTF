extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("rest")
	
func play_alert():
	$AnimatedSprite2D.play("alert")

func play_chase():
	$AnimatedSprite2D.play("chase")
