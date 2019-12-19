extends Spatial

export var speed = 1

onready var animation = $AnimationPlayer

func show():
	animation.play("Extend", -1, speed)

func hide():
	animation.play("Contract", -1, speed)
