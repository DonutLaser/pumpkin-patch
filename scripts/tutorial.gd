extends Spatial

onready var children = get_children()

func _on_level_completed():
	for child in children:
		child.fade_out()
