extends Node2D

func _ready():
	pass # Replace with function body.

func update_needle(t):
	$Needle.set_rotation(PI*t-PI/2)
