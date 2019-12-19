extends Spatial

signal activated
signal deactivated

export (NodePath) var gate_node

onready var raycast = $RayCast
onready var highlight = $Highlight
var active = false

func _ready():
	var gate = get_node(gate_node)
	connect("activated", gate, "_on_goal_activated")
	connect("deactivated", gate, "_on_goal_deactivated")

func _physics_process(delta):
	var obj = raycast.get_collider()
	if obj && obj.is_in_group("movable_object"):
		if not active:
			emit_signal("activated")
			active = true
			highlight.show()
	else:
		if active:
			emit_signal("deactivated")
			active = false
			highlight.hide()
