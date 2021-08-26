extends KinematicBody2D

var speed = 80
var packed_death_particles = preload("res://nodes/DeathParticles.tscn")

var player
var velocity

func _ready():
	add_to_group("enemies")

func init(player_ref):
	player = player_ref

func _physics_process(delta):
	velocity = (player.get_position() - get_position()).normalized() * speed
	velocity = move_and_slide(velocity)

func destroy():
	if not is_queued_for_deletion():
		var particles = packed_death_particles.instance()
		particles.set_position(get_position())
		get_parent().add_child(particles)
		queue_free()
