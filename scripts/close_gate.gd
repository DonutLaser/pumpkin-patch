extends RayCast

signal close_gate

func _physics_process(delta):
	if enabled:
		var collider = self.get_collider()

		if collider && collider.is_in_group("player"):
			emit_signal("close_gate")
			enabled = false
