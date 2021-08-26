extends Node2D

var floor_textures = [
	preload("res://assets/sprites/floor.png")
]
var map_height = 16
var map_width = 24
var player_start_grid_position = Vector2(map_width/2, map_height/2)
var move_timer = 6.0
var packed_projectile = preload("res://nodes/Projectile.tscn")
var projectile_timer = 0.5
var projectile_offset = Vector2(-24, 0)
var wall_width = 10
var packed_enemy = preload("res://nodes/Enemy.tscn")
var enemy_timer = 1.6

var map_midpoint

func _ready():
	map_midpoint = get_viewport_rect().size / 2
	init_move_timer()
	init_projectile_timer()
	init_map()
	init_indicator()
	init_enemy_spawner()
	add_player()

func init_move_timer():
	var _discard = $MoveTimer.connect("timeout", self, "move_timer_callback")
	$MoveTimer.set_wait_time(move_timer)
	$MoveTimer.start()

func init_projectile_timer():
	var _discard = $ProjectileTimer.connect("timeout", self, "projectile_timer_callback")
	$ProjectileTimer.set_one_shot(true)
	$ProjectileTimer.set_wait_time(projectile_timer)
	$ProjectileTimer.start()

func init_map():
	$Grid.init(floor_textures, map_height, map_width)
	$Grid.set_position(map_midpoint)
	$Entities.set_position(map_midpoint)
	$Projectiles.set_position(map_midpoint)
	setup_walls()

func init_indicator():
	$Indicator.init($Grid)
	$Indicator.start_new_path(player_start_grid_position)
	$Indicator.refresh_trail()
	$Indicator.set_position(map_midpoint)

func setup_walls():
	# Top
	var top_wall = StaticBody2D.new()
	top_wall.add_to_group("walls")
	var horizontal_collision_shape = CollisionShape2D.new()
	var horizontal_shape = RectangleShape2D.new()
	horizontal_shape.extents = Vector2($Grid.size.x/2 + wall_width*2, wall_width)
	horizontal_collision_shape.shape = horizontal_shape
	top_wall.add_child(horizontal_collision_shape)
	top_wall.set_position(map_midpoint - Vector2(0, $Grid.size.y/2 + wall_width))
	add_child(top_wall)
	# Bottom
	var bottom_wall = StaticBody2D.new()
	bottom_wall.add_to_group("walls")
	horizontal_collision_shape = CollisionShape2D.new()
	horizontal_shape = RectangleShape2D.new()
	horizontal_shape.extents = Vector2($Grid.size.x/2 + wall_width*2, wall_width)
	horizontal_collision_shape.shape = horizontal_shape
	bottom_wall.add_child(horizontal_collision_shape)
	bottom_wall.set_position(map_midpoint + Vector2(0, $Grid.size.y/2 + wall_width))
	add_child(bottom_wall)
	# Left
	var left_wall = StaticBody2D.new()
	left_wall.add_to_group("walls")
	var vertical_collision_shape = CollisionShape2D.new()
	var vertical_shape = RectangleShape2D.new()
	vertical_shape.extents = Vector2(wall_width, $Grid.size.y/2 + wall_width*2)
	vertical_collision_shape.shape = vertical_shape
	left_wall.add_child(vertical_collision_shape)
	left_wall.set_position(map_midpoint - Vector2($Grid.size.x/2 + wall_width, 0))
	add_child(left_wall)
	# Right
	var right_wall = StaticBody2D.new()
	right_wall.add_to_group("walls")
	vertical_collision_shape = CollisionShape2D.new()
	vertical_shape = RectangleShape2D.new()
	vertical_shape.extents = Vector2(wall_width, $Grid.size.y/2 + wall_width*2)
	vertical_collision_shape.shape = vertical_shape
	right_wall.add_child(vertical_collision_shape)
	right_wall.set_position(map_midpoint + Vector2($Grid.size.x/2 + wall_width, 0))
	add_child(right_wall)

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
		$MoveTimer.start()

func move_timer_callback():
	$Indicator.set_active(false)
	$Entities/Player.move_along_path($Indicator.get_current_path())

func _input(event):
	if event.is_action_pressed("ui_up"):
		$Indicator.input(Vector2(0, -1))
	elif event.is_action_pressed("ui_down"):
		$Indicator.input(Vector2(0, 1))
	elif event.is_action_pressed("ui_left"):
		$Indicator.input(Vector2(-1, 0))
	elif event.is_action_pressed("ui_right"):
		$Indicator.input(Vector2(1, 0))
	if event is InputEventMouseMotion:
		$Entities/Player.update_mouse_position(event.position)

func _process(_delta):
	update_hud()

func update_hud():
	# DEBUG
	$Label.text = str(round($MoveTimer.get_time_left()))

func projectile_timer_callback():
	spawn_projectile()
	$ProjectileTimer.set_wait_time(projectile_timer)
	$ProjectileTimer.start()

func spawn_projectile():
	var projectile = packed_projectile.instance()
	var projectile_angle = $Entities/Player/Turret.get_rotation()
	projectile.set_position(
		$Entities/Player.get_position() + projectile_offset.rotated(projectile_angle)
	)
	projectile.set_rotation(projectile_angle)
	$Projectiles.add_child(projectile)

func init_enemy_spawner():
	var _discard = $EnemyTimer.connect("timeout", self, "enemy_timer_callback")
	$EnemyTimer.set_wait_time(enemy_timer)
	$EnemyTimer.start()

func enemy_timer_callback():
	var enemy = packed_enemy.instance()
	enemy.init($Entities/Player)
	enemy.set_position(
		Vector2(
			rand_range(-$Grid.size.x/2, $Grid.size.x/2),
			rand_range(-$Grid.size.y/2, $Grid.size.y/2)
		)
	)
	$Entities.add_child(enemy)
