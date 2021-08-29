extends Area2D

signal pickup

var tween_time = 0.5

var pickup_type

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	var _discard = connect("area_entered", self, "area_entered_callback")

func health_pickup():
	pickup_type = "health"
	$Sprite.texture = load("res://assets/sprites/pickup_crates/health.png")

func fire_rate_pickup():
	pickup_type = "fire_rate"
	$Sprite.texture = load("res://assets/sprites/pickup_crates/fire_rate.png")

func area_entered_callback(area):
	if area.is_in_group("player"):
		audio.play_sound("powerup")
		destroy()

func destroy():
	emit_signal("pickup", pickup_type)
	set_z_index(99)
	$Tween.interpolate_property(
		self,
		"scale",
		Vector2(1.0, 1.0),
		Vector2(3.0, 3.0),
		tween_time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	$Tween.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, 1),
		Color(1, 1, 1, 0),
		tween_time,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	var _discard = $Tween.connect("tween_all_completed", self,
		"queue_free", [], CONNECT_ONESHOT)
	$Tween.start()
