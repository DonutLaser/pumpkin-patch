extends RayCast

signal next_level_started

func _ready():
	var camera = get_tree().get_nodes_in_group("camera")[0]
	connect("next_level_started", camera, "_on_next_level_started")

func _physics_process(delta):
	if enabled:
		var collider = self.get_collider()

		if collider && collider.is_in_group("player"):
			emit_signal("next_level_started")
			enabled = false
