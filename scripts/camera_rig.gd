extends Spatial

export var move_speed = 1
export var rotation_speed = 1

var can_move_up = false

func _process(delta):
	rotation_degrees += Vector3(0, rotation_speed * delta, 0)

	if can_move_up:
		translation += Vector3(0, move_speed * delta, 0)


func _move_up():
	can_move_up = true
