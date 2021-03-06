extends StaticBody2D

signal moving_change
signal player_health_change
signal player_died

var move_time = 0.4
var damage_amount = 1
var heal_amount = 2
var packed_death_particles = preload("res://nodes/PlayerDeathParticles.tscn")

var max_rotation_speed = 2*PI
var min_rotation_speed = 1.2*PI

var rotation_speed = (max_rotation_speed+min_rotation_speed) / 2.0
var health = 10
var grid
var current_grid_path = []
var moving = false
var mouse_position
var grid_position

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	var _return = $Tween.connect("tween_all_completed", self, "tween_to_next_grid_position")

func init(grid_ref):
	grid = grid_ref

func set_grid_position(input_grid_position):
	grid_position = input_grid_position
	set_position(grid.get_pixel_position(input_grid_position))

func move_along_path(input_grid_path):
	current_grid_path = input_grid_path
	moving = true
	emit_signal("moving_change", moving)
	tween_to_next_grid_position()

func tween_to_next_grid_position():
	grid_position = current_grid_path.pop_front()
	if len(current_grid_path) == 0:
		moving = false
		emit_signal("moving_change", moving)
		tracks_stop()
		return
	var target = grid.get_pixel_position(current_grid_path[0])
	if check_rotation_required(current_grid_path[0]):
		current_grid_path.push_front(grid_position)
	else:
		tracks_forward()
		$Tween.interpolate_property(self, "position", position, target, move_time)
		$Tween.start()

func check_rotation_required(target):
	var current_angle = normalise_radians($Base.rotation)
	var target_angle = normalise_radians(grid_position.angle_to_point(target)-PI/2)
	if not abs(current_angle - target_angle) < 0.01:
		tracks_rotate()
		$Tween.interpolate_property($Base, "rotation", current_angle, target_angle, move_time)
		$Tween.start()
		return(true)
	return(false)

func update_mouse_position(input_mouse_position):
	mouse_position = input_mouse_position

func _process(delta):
	animate_turret_rotation(delta)

func animate_turret_rotation(delta):
	var target_turret_angle = 0
	if mouse_position:
		target_turret_angle = get_global_position().angle_to_point(mouse_position)
	var anticlockwise_distance = normalise_radians($Turret.rotation - target_turret_angle)
	var clockwork_distance = normalise_radians(target_turret_angle - $Turret.rotation)
	var rotation_direction = 1
	if anticlockwise_distance < clockwork_distance:
		rotation_direction = -1
	if min(clockwork_distance, anticlockwise_distance) > 2*PI/100:
		$Turret.rotation += rotation_direction*delta*rotation_speed
	$Turret.rotation = fmod($Turret.rotation, 2*PI)

func normalise_radians(input_radians):
	# normalised input_radians to between 0 and 2PI
	while input_radians < 0:
		input_radians += 2*PI
	while 2*PI < input_radians:
		input_radians -= 2*PI
	return(input_radians)

func tracks_forward():
	for node in [$Base/LeftTrack, $Base/RightTrack]:
		node.play("moving")
		node.flip_v = true

func tracks_stop():
	for node in [$Base/LeftTrack, $Base/RightTrack]:
		node.play("idle")

func tracks_rotate():
	$Base/LeftTrack.play("moving")
	$Base/LeftTrack.flip_v = true
	$Base/RightTrack.play("moving")
	$Base/RightTrack.flip_v = false

func damage():
	audio.play_sound("hit")
	health = clamp(health-damage_amount, 0, 10)
	emit_signal("player_health_change", health/10.0)
	if health == 0:
		destroy()

func heal():
	health = clamp(health+heal_amount, 0, 10)
	emit_signal("player_health_change", health/10.0)

func destroy():
	if not is_queued_for_deletion():
		audio.play_sound("explosion")
		var particles = packed_death_particles.instance()
		particles.set_position(get_position())
		get_parent().add_child(particles)
		emit_signal("player_died", particles)
		queue_free()

func update_rotation_speed(t):
	rotation_speed = lerp(min_rotation_speed, max_rotation_speed, t)
