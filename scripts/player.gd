extends Spatial

signal move
 
export var speed = 1
export var grid_size = 2
export(String) var ground_particle;

enum Direction { UP = 0, RIGHT = 1, DOWN = 2, LEFT = 3, _COUNT = 4 } 
enum MoveType { NONE, MOVE, PUSH }

onready var raycasts = [
	Vector3(0, 5, -grid_size), 
	Vector3(grid_size, 5, 0), 
	Vector3(0, 5, grid_size), 
	Vector3(-grid_size, 5, 0)
]
onready var raycasts_far = [
	Vector3(0, 5, -grid_size * 2), 
	Vector3(grid_size * 2, 5, 0), 
	Vector3(0, 5, grid_size * 2), 
	Vector3(-grid_size * 2, 5, 0)
]
onready var animation = $AnimationPlayer

var scripted_moves = [
	{ "direction": Vector3(0, 0, 1), "look_angle": 0 },
	{ "direction": Vector3(-1, 0, 0), "look_angle": -90 },
	{ "direction": Vector3(-1, 0, 0), "look_angle": -90 },
	{ "direction": Vector3(0, 0, -1), "look_angle": 180 },
	{ "direction": Vector3(0, 0, -1), "look_angle": 180 },
	{ "direction": Vector3(1, 0, 0), "look_angle": 90 },
	{ "direction": Vector3(1, 0, 0), "look_angle": 90 },
	{ "direction": Vector3(0, 0, 1), "look_angle": 0 },
]

var lerp_start = 0.0
var moving = false
var target_position = Vector3(0, 0, 0)
var start_position = Vector3(0, 0, 0)
var raycast = false
var raycast_dir = Vector3(0, -10, 0)
var available_dirs = [MoveType.NONE, MoveType.NONE, MoveType.NONE, MoveType.NONE]
var ready_to_push_objects = [null, null, null, null]
var can_move = true 
var scripted_sequence = false
var current_scripted_move = 0
var particle;

func _on_camera_start_transition():
	can_move = false

func _on_camera_end_transition():
	raycast = true
	yield(get_tree(), "idle_frame")
	can_move = true

func _start_scripted_sequence():
	scripted_sequence = true
	_scripted_move()

func _undo(last_position):
	translation = last_position["from"]
	rotation_degrees = last_position["rotation"]

	if last_position["object"] != null:
		last_position["object"].translation = last_position["object_from"]

	yield(get_tree(), "idle_frame")
	raycast = true

func _scripted_move():
	var move = scripted_moves[current_scripted_move]
	current_scripted_move += 1

	_move(move.direction, move.look_angle, MoveType.MOVE, null)

func _move(dir, look_angle, move_type, pushed_object):
	rotation_degrees = Vector3(0, look_angle, 0)

	if move_type == MoveType.MOVE:
		start_position = translation
		target_position = translation + dir * grid_size
		moving = true
		$CollisionShape.disabled = true
		emit_signal("move", start_position, rotation_degrees, null, null)
		animation.play("Move", -1, speed / 2)

		_spawn_particle(start_position)
	elif move_type == MoveType.PUSH:
		start_position = translation
		target_position = translation + dir * grid_size
		moving = true

		$CollisionShape.disabled = true
		emit_signal("move", start_position, rotation_degrees, pushed_object, pushed_object.translation)

		if pushed_object:
			pushed_object.move(dir, grid_size)

		animation.play("Move", -1, speed / 2)

		_spawn_particle(start_position)


func _spawn_particle(position):
	var instance = particle.instance()
	instance.set_name("particle")
	instance.translation = position
	get_tree().get_root().add_child(instance)

func _ready():
	raycast = true;
	particle = load(ground_particle)


func _process(delta):
	if moving:
		lerp_start += delta * speed
		translation = start_position.linear_interpolate(target_position, lerp_start)
		if lerp_start >= 1.0:
			moving = false
			lerp_start = 0.0
			raycast = true
			translation = target_position
			$CollisionShape.disabled = false 

			if animation.is_playing():
				animation.stop()

			if scripted_sequence:
				if current_scripted_move == scripted_moves.size():
					current_scripted_move = 0

				_scripted_move()

		return

	if !can_move:
		return

	if Input.is_action_just_pressed("up"):
		_move(Vector3(0, 0, -1), 180, available_dirs[Direction.UP], ready_to_push_objects[Direction.UP])
	elif Input.is_action_just_pressed("right"):
		_move(Vector3(1, 0, 0), 90, available_dirs[Direction.RIGHT], ready_to_push_objects[Direction.RIGHT])
	elif Input.is_action_just_pressed("down"):
		_move(Vector3(0, 0, 1), 0, available_dirs[Direction.DOWN], ready_to_push_objects[Direction.DOWN])
	elif Input.is_action_just_pressed("left"):
		_move(Vector3(-1, 0, 0), -90, available_dirs[Direction.LEFT], ready_to_push_objects[Direction.LEFT])


func _physics_process(delta):
	if raycast:
		var space_state = get_world().direct_space_state
		for i in range(0, Direction._COUNT):
			var from = translation + raycasts[i]
			var to = from + raycast_dir
			var near_result = space_state.intersect_ray(from, to, [], 2147483647, false, true)
			if not near_result.empty():
				if near_result.collider.is_in_group("static_object"):
					available_dirs[i] = MoveType.NONE
				else:
					var far_from = translation + raycasts_far[i]
					var far_to = far_from + raycast_dir
					var far_result = space_state.intersect_ray(far_from, far_to, [], 2147483647, false, true)
					if far_result.empty():
						available_dirs[i] = MoveType.PUSH
						ready_to_push_objects[i] = near_result.collider
					else:
						available_dirs[i] = MoveType.NONE
			else:
				available_dirs[i] = MoveType.MOVE 

		raycast = false
