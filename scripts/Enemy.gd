extends KinematicBody2D

var speed = 80
var packed_death_particles = preload("res://nodes/DeathParticles.tscn")

var player
var nav
var velocity

func _ready():
	add_to_group("enemies")

func init(player_ref, nav_ref):
	player = player_ref
	nav = nav_ref

func _physics_process(_delta):
	if is_instance_valid(player) and not player.is_queued_for_deletion():
		var path = nav.get_simple_path(
			nav.to_local(get_global_position()),
			nav.to_local(player.get_global_position())
		)
		velocity = (nav.to_global(path[1]) - get_global_position()).normalized() * speed
		velocity = move_and_slide(velocity)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("player"):
				if not is_queued_for_deletion():
					collision.collider.damage()
					destroy()

func destroy():
	if not is_queued_for_deletion():
		var particles = packed_death_particles.instance()
		particles.set_position(get_position())
		get_parent().add_child(particles)
		queue_free()
