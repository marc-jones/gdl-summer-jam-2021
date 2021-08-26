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

func _physics_process(delta):
	var path = nav.get_simple_path(
		nav.to_local(get_global_position()),
		nav.to_local(player.get_global_position())
	)
	velocity = (nav.to_global(path[1]) - get_global_position()).normalized() * speed
	velocity = move_and_slide(velocity)

func destroy():
	if not is_queued_for_deletion():
		var particles = packed_death_particles.instance()
		particles.set_position(get_position())
		get_parent().add_child(particles)
		queue_free()
