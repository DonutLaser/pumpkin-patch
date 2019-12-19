extends Spatial

onready var fade_animation = $ColorRect/AnimationPlayer

func _ready():
	fade_animation.play("fade_in")

func _on_fade_out(animation):
	if animation == "FadeOut":
		get_tree().change_scene("res://levels/menu.tscn")
