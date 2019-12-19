extends Spatial

onready var animation = $AnimationPlayer

func fade_out():
	animation.play("FadeOut");