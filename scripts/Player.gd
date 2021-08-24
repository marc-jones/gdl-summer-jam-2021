extends Node2D

signal moving_change

var move_time = 0.4
var rotation_speed = 1.2*PI

var grid
var current_grid_path = []
var moving = false
var mouse_position

func _ready():
	var _return = $Tween.connect("tween_all_completed", self, "tween_to_next_grid_position")

func init(grid_ref):
	grid = grid_ref

func set_grid_position(input_grid_position):
	set_position(grid.get_pixel_position(input_grid_position))

func move_along_path(input_grid_path):
	current_grid_path = input_grid_path
	moving = true
	emit_signal("moving_change", moving)
	tween_to_next_grid_position()

func tween_to_next_grid_position():
	current_grid_path.pop_front()
	if len(current_grid_path) == 0:
		moving = false
		emit_signal("moving_change", moving)
		return
	var target = grid.get_pixel_position(current_grid_path[0])
	$Tween.interpolate_property(self, "position", position, target, move_time)
	$Tween.start()

func update_mouse_position(input_mouse_position):
	mouse_position = input_mouse_position

func _process(delta):
	animate_rotation(delta)

func animate_rotation(delta):
	var target_turret_angle = 0
	if mouse_position:
		target_turret_angle = get_global_position().angle_to_point(mouse_position)
	var anticlockwise_distance = $Turret.rotation - target_turret_angle
	var clockwork_distance = target_turret_angle - $Turret.rotation
	while clockwork_distance < 0:
		clockwork_distance += 2*PI
	while anticlockwise_distance < 0:
		anticlockwise_distance += 2*PI
	while 2*PI < clockwork_distance:
		clockwork_distance -= 2*PI
	while 2*PI < anticlockwise_distance:
		anticlockwise_distance -= 2*PI
	var rotation_direction = 1
	if anticlockwise_distance < clockwork_distance:
		rotation_direction = -1
	if min(clockwork_distance, anticlockwise_distance) > 2*PI/100:
		$Turret.rotation += rotation_direction*delta*rotation_speed
	$Turret.rotation = fmod($Turret.rotation, 2*PI)
