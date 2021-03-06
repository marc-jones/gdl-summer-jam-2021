extends Node2D

var lifetime = 5.0

func _ready():
	for node_name in ["Particles1", "Particles2"]:
		setup_particles(node_name)
	$RemoveTimer.wait_time = lifetime
	var _discard = $RemoveTimer.connect("timeout", self, "queue_free")

func setup_particles(node_name):
	var node = get_node(node_name)
	node.emitting = true
	node.lifetime = lifetime
