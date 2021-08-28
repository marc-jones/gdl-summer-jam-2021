extends Node2D

var update_delay = 0.5
var update_speed = 0.1

var current_value = 1.0
var lag_value = current_value
var update_timer = 0.0

func take_damage(amount):
	current_value -= amount
	update_timer = update_delay

func _process(delta):
	if update_timer > 0:
		update_timer -= delta
	if update_timer <= 0:
		lag_value -= (lag_value - current_value) * update_speed
	$Bar.get_material().set_shader_param("current_value", current_value)
	$LagBar.get_material().set_shader_param("current_value", lag_value)
