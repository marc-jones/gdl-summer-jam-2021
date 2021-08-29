extends KinematicBody2D

signal enemy_killed

var speed = 80
var packed_death_particles = preload("res://nodes/DeathParticles.tscn")

var player
var nav
var velocity

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	add_to_group("enemies")
	$AnimationPlayer.play("spawn")

func init(player_ref, nav_ref):
	player = player_ref
	nav = nav_ref

func _physics_process(_delta):
	if (is_instance_valid(player) and
		not player.is_queued_for_deletion() and
		not $AnimationPlayer.is_playing()):
		var path = nav.get_simple_path(
			nav.get_closest_point(nav.to_local(get_global_position())),
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

func shot():
	emit_signal("enemy_killed")
	audio.play_sound("explosion")
	destroy()
