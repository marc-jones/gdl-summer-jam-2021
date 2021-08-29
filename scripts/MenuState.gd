extends Node2D

signal start_game

func _ready():
	$Buttons/HBox/Start.connect(
		"button_up", self, "emit_signal", ["start_game"])

func _process(_delta):
	$Controls/FreezeIndicator.update_sprites(
		clamp($FreezeTimer.get_time_left()-1.0, 0.0, 6.0)
	)
