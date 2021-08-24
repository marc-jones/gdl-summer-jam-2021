extends Node2D


var floor_textures = [
	preload("res://assets/sprites/floor.png")
]

var map_midpoint

func _ready():
	map_midpoint = get_viewport_rect().size / 2
	init_grid()
	init_indicator()

func init_grid():
	$Grid.init(floor_textures)
	$Grid.set_position(map_midpoint)

func init_indicator():
	$Indicator.init($Grid)
	$Indicator.refresh_trail()
	$Indicator.set_position(map_midpoint)

func _input(event):
	if event.is_action_pressed("ui_up"):
		$Indicator.input(Vector2(0, -1))
	elif event.is_action_pressed("ui_down"):
		$Indicator.input(Vector2(0, 1))
	elif event.is_action_pressed("ui_left"):
		$Indicator.input(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right"):
		$Indicator.input(Vector2(1, 0))
