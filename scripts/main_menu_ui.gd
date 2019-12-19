extends Control

signal transition_to_new_game

onready var fade_animation = $ColorRect/AnimationPlayer
onready var new_game_button = get_node("VBoxContainer/New Game")
onready var buttons = $VBoxContainer
onready var logo = $TextureRect

func _ready():
	new_game_button.grab_focus()

func _on_quit():
	get_tree().quit()

func _on_new_game():
	emit_signal("transition_to_new_game")
	fade_animation.play("fade_out")
	buttons.visible = false
	logo.visible = false

func _start_game(animation_name):
	get_tree().change_scene("res://levels/main.tscn")
