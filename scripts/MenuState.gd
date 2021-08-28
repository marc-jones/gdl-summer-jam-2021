extends Node2D

signal start_game

func _ready():
	$Buttons/HBox/Start.connect(
		"button_up", self, "emit_signal", ["start_game"])
