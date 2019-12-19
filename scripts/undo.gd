extends Node

signal undo

var stack = []

func _on_register_undo_step(player_from, rotation, pushed_object, pushed_object_from):
	stack.push_back({ 
		"from": player_from, 
		"rotation": rotation,
		"object": pushed_object,
		"object_from": pushed_object_from
	})

func _process(delta):
	if Input.is_action_just_pressed("undo"):
		if stack.size() != 0:
			emit_signal("undo", stack.pop_back())

