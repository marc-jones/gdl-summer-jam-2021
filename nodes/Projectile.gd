extends Area2D

var speed = 200.0

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	position += Vector2.LEFT.rotated(rotation) * delta * speed
