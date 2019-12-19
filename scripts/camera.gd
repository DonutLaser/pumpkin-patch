extends Camera

signal start_transition 
signal end_transition
signal finale

export var nodes = []
export var speed = 1

onready var win_screen_animation = get_node("../Win/TextureRect/AnimationPlayer")
onready var timer = $Timer
onready var fade_out_animation = get_node("../ColorRect/AnimationPlayer")

var current_node = 0
var move = false
var target_position = Vector3(0, 0, 0)
var start_position = Vector3(0, 0, 0)
var lerp_start = 0.0

func _move(target):
	move = true
	target_position = target
	start_position = translation

func _on_next_level_started():
	current_node += 1
	_move(nodes[current_node])
	emit_signal("start_transition")

func _on_exit():
	current_node += 1
	_move(nodes[current_node])
	fade_out_animation.play("FadeOut")

func _ready():
	var player = get_tree().get_nodes_in_group("player")[0]
	connect("start_transition", player, "_on_camera_start_transition")
	connect("end_transition", player, "_on_camera_end_transition")

	_move(nodes[current_node])

func _process(delta):
	if move:
		lerp_start += delta * speed
		translation = start_position.linear_interpolate(target_position, lerp_start)
		if lerp_start >= 1.0:
			move = false
			lerp_start = 0.0
			emit_signal("end_transition")

			if current_node == nodes.size() - 2:
				emit_signal("finale")
				win_screen_animation.play("ShowUp")
				timer.start()
