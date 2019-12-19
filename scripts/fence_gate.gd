extends Area

signal open

export var required_goals = 0
export var open_speed = 1
export var close_speed = 1

var current_active_goals = 0
var opening = false
var closing = false
var current_rotation = 0 

onready var left_gate = get_node("Left Gate Pivot")
onready var right_gate = get_node("Right Gate Pivot")

func _open():
	$Lock.visible = false
	$CollisionShape.disabled = true
	opening = true
	emit_signal("open")

func _close():
	$Lock.visible = true
	$CollisionShape.disabled = false
	closing = true

func _close_no_lock():
	$CollisionShape.disabled = false
	closing = true

func _on_goal_activated():
	current_active_goals += 1

	if current_active_goals == required_goals:
		_open()

func _on_goal_deactivated():
	current_active_goals -= 1

	if current_active_goals != required_goals:
		_close()

func _on_close_gate():
	_close_no_lock()

func _process(delta):
	if opening:
		current_rotation += open_speed * delta
		left_gate.rotation_degrees = Vector3(0, -current_rotation, 0)
		right_gate.rotation_degrees = Vector3(0, current_rotation, 0)

		if current_rotation >= 90:
			opening = false
			current_rotation = 90
			left_gate.rotation_degrees = Vector3(0, -current_rotation, 0)
			right_gate.rotation_degrees = Vector3(0, current_rotation, 0)

	elif closing:
		current_rotation -= close_speed * delta
		left_gate.rotation_degrees = Vector3(0, -current_rotation, 0)
		right_gate.rotation_degrees = Vector3(0, current_rotation, 0)

		if current_rotation <= 0:
			closing = false
			current_rotation = 0
			left_gate.rotation_degrees = Vector3(0, current_rotation, 0)
			right_gate.rotation_degrees = Vector3(0, current_rotation, 0)

