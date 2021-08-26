extends KinematicBody2D

var packed_death_particles = preload("res://nodes/DeathParticles.tscn")

var velocity = Vector2(50, 50)

func _ready():
	add_to_group("enemies")

func _physics_process(delta):
	velocity = move_and_slide(velocity)

func destroy():
	if not is_queued_for_deletion():
		var particles = packed_death_particles.instance()
		particles.set_position(get_position())
		get_parent().add_child(particles)
		queue_free()
