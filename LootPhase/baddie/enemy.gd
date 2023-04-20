extends Node2D

#animation cycling script

func _ready():
	$AnimatedSprite2D.play("rest")
	
func play_alert():
	$AnimatedSprite2D.play("alert")

func play_chase():
	$AnimatedSprite2D.play("chase")
