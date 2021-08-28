extends Node2D

var floor_textures = [
	preload("res://assets/sprites/floor.png")
]
var map_height = 16
var map_width = 24
var player_start_grid_position = Vector2(map_width/2, map_height/2)
var move_timer = 6.0
var packed_projectile = preload("res://nodes/Projectile.tscn")
var projectile_offset = Vector2(-24, 0)
var wall_width = 10
var packed_enemy = preload("res://nodes/Enemy.tscn")
var enemy_timer = 1.6
var player_dead_zone_radius = 200
var packed_pickup = preload("res://nodes/Pickup.tscn")
var pickup_timer = 5.0

var max_projectile_timer = 0.05
var min_projectile_timer = 0.8
var projectile_timer_decay_rate = 0.025

var projectile_timer = (max_projectile_timer + min_projectile_timer) / 2
var map_midpoint
var score = 0

func _ready():
	init_move_timer()
	init_projectile_timer()
	init_pickup_timer()
	init_map()
	init_indicator()
	init_enemy_spawner()
	add_player()
	spawn_pickup()

func init_move_timer():
	var _discard = $MoveTimer.connect("timeout", self, "move_timer_callback")
	$MoveTimer.set_wait_time(move_timer)
	$MoveTimer.start()

func init_projectile_timer():
	var _discard = $ProjectileTimer.connect("timeout", self, "projectile_timer_callback")
	$ProjectileTimer.set_one_shot(true)
	$ProjectileTimer.set_wait_time(projectile_timer)
	$ProjectileTimer.start()

func init_pickup_timer():
	var _discard = $PickupTimer.connect("timeout", self, "pickup_timer_callback")
	$PickupTimer.set_one_shot(true)
	$PickupTimer.set_wait_time(pickup_timer)
	$PickupTimer.start()

func init_map():
	$Grid.init(floor_textures, map_height, map_width)
	map_midpoint = $Navigation2D.get_position() + $Grid.size / 2
	$Grid.set_position(map_midpoint)
	$Entities.set_position(map_midpoint)
	$Projectiles.set_position(map_midpoint)
	$Pickups.set_position(map_midpoint)

func init_indicator():
	$Indicator.init(
		$Grid,
		$Navigation2D/TileMap.get_used_cells_by_id(1)
	)
	$Indicator.start_new_path(player_start_grid_position)
	$Indicator.refresh_trail()
	$Indicator.set_position(map_midpoint)

func add_player():
	var packed_player = load("res://nodes/Player.tscn")
	var player = packed_player.instance()
	player.connect("player_health_change", $HUD/HealthIndicator, "set_health")
	player.connect("player_died", self, "player_died_callback")
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
	if $Entities.has_node("Player"):
		$Entities/Player.move_along_path($Indicator.get_current_path())

func _input(event):
	if $Entities.has_node("Player"):
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

func _process(delta):
	update_rates(delta)
	update_hud()

func update_hud():
	$HUD/FreezeIndicator.update_sprites($MoveTimer.get_time_left())
	var fire_rate_t = (projectile_timer-min_projectile_timer) / (max_projectile_timer-min_projectile_timer)
	$HUD/FireRateIndicator.update_needle(fire_rate_t)
	if $Entities.has_node("Player"):
		$Entities/Player.update_rotation_speed(fire_rate_t)

func update_rates(delta):
	projectile_timer = clamp(
		projectile_timer + projectile_timer_decay_rate*delta,
		max_projectile_timer,
		min_projectile_timer
	)

func projectile_timer_callback():
	if $Entities.has_node("Player"):
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

func pickup_timer_callback():
	if $Entities.has_node("Player"):
		spawn_pickup()
	$PickupTimer.set_wait_time(pickup_timer)
	$PickupTimer.start()

func spawn_pickup():
	var current_pickups = $Pickups.get_children()
	if $Entities.has_node("Player") and len(current_pickups) < 2:
		var has_health = false
		for pickup in current_pickups:
			if pickup.pickup_type == "health":
				has_health = true
		var pickup = packed_pickup.instance()
		pickup.connect("pickup", self, "pickup_callback")
		if $Entities/Player.health == 10 or has_health:
			pickup.fire_rate_pickup()
		else:
			if randf() < 0.5:
				pickup.fire_rate_pickup()
			else:
				pickup.health_pickup()
		var pickup_position = $Entities/Player.get_position()
		var possible_grid_positions = $Navigation2D/TileMap.get_used_cells_by_id(0)
		possible_grid_positions.shuffle()
		while (pickup_position.distance_to($Entities/Player.get_position()) <
			player_dead_zone_radius):
			pickup_position = $Grid.get_pixel_position(possible_grid_positions.pop_front())
		pickup.set_position(pickup_position)
		$Pickups.add_child(pickup)

func pickup_callback(pickup_type):
	match pickup_type:
		"fire_rate":
			projectile_timer = max_projectile_timer
		"health":
			$Entities/Player.heal()

func init_enemy_spawner():
	var _discard = $EnemyTimer.connect("timeout", self, "enemy_timer_callback")
	$EnemyTimer.set_wait_time(enemy_timer)
	$EnemyTimer.start()

func enemy_timer_callback():
	if $Entities.has_node("Player"):
		var enemy = packed_enemy.instance()
		enemy.init($Entities/Player, $Navigation2D)
		var enemy_position = $Entities/Player.get_position()
		var possible_grid_positions = $Navigation2D/TileMap.get_used_cells_by_id(0)
		possible_grid_positions.shuffle()
		while (enemy_position.distance_to($Entities/Player.get_position()) <
			player_dead_zone_radius):
			enemy_position = $Grid.get_pixel_position(possible_grid_positions.pop_front())
		enemy.set_position(enemy_position)
		enemy.connect("enemy_killed", self, "enemy_died_callback")
		$Entities.add_child(enemy)

func enemy_died_callback():
	score += 1
	$HUD/Score/Number.text = str(score)

func player_died_callback(player_death_particles):
	$Indicator.start_new_path(Vector2(0, 0))
	$Indicator.refresh_trail()
	print(player_death_particles)
