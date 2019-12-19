extends Area

export var speed = 1

var lerp_start = 0.0
var moving = false
var target_position = Vector3(0, 0, 0)
var start_position = Vector3(0, 0, 0)

func move(dir, grid_size):
	start_position = translation
	target_position = translation + dir * grid_size
	moving = true

func _process(delta):
	if moving:
		lerp_start += delta * speed
		translation = start_position.linear_interpolate(target_position, lerp_start)
		if lerp_start >= 1.0:
			moving = false
			translation = target_position
			lerp_start = 0.0
