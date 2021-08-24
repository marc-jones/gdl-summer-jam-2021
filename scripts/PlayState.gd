extends Node2D

var floor_textures = [
	preload("res://assets/sprites/floor.png")
]
var map_height = 16
var map_width = 24
var player_start_grid_position = Vector2(map_width/2, map_height/2)

var map_midpoint

func _ready():
	map_midpoint = get_viewport_rect().size / 2
	init_map()
	init_indicator()
	add_player()

func init_map():
	$Grid.init(floor_textures, map_height, map_width)
	$Grid.set_position(map_midpoint)
	$Entities.set_position(map_midpoint)

func init_indicator():
	$Indicator.init($Grid)
	$Indicator.start_new_path(player_start_grid_position)
	$Indicator.refresh_trail()
	$Indicator.set_position(map_midpoint)

func add_player():
	var packed_player = load("res://nodes/Player.tscn")
	var player = packed_player.instance()
	player.init($Grid)
	player.set_grid_position(player_start_grid_position)
	var _return = player.connect("moving_change", self, "player_move_change")
	$Entities.add_child(player)

func player_move_change(moving_bool):
	if moving_bool:
		pass
	else:
		$Indicator.set_active(true)
		$Indicator.start_new_path(
			$Grid.get_grid_position($Entities/Player.get_position())
		)

func _input(event):
	if event.is_action_pressed("ui_up"):
		$Indicator.input(Vector2(0, -1))
	elif event.is_action_pressed("ui_down"):
		$Indicator.input(Vector2(0, 1))
	elif event.is_action_pressed("ui_left"):
		$Indicator.input(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right"):
		$Indicator.input(Vector2(1, 0))
	elif event.is_action_pressed("ui_accept"):
		# DEBUG
		$Entities/Player.move_along_path($Indicator.get_current_path())
		$Indicator.set_active(false)
	if event is InputEventMouseMotion:
		$Entities/Player.update_mouse_position(event.position)
