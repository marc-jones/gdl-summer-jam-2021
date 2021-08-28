extends Area2D

var speed = 200.0

func _ready():
	var _discard = connect("body_entered", self, "body_entered_callback")

func _physics_process(delta):
	position += Vector2.LEFT.rotated(rotation) * delta * speed

func body_entered_callback(body):
	if body.is_in_group("walls"):
		destroy()
	elif body.is_in_group("enemies"):
		destroy()
		body.emit_signal("enemy_killed")
		body.destroy()

func destroy():
	if not is_queued_for_deletion():
		var particles = get_node("Particles2D")
		particles.emitting = false
		var death_timer = particles.get_node("DeathTimer")
		death_timer.wait_time = particles.lifetime
		death_timer.connect("timeout", particles, "queue_free")
		death_timer.start()
		remove_child(particles)
		get_parent().add_child(particles)
		queue_free()
