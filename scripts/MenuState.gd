extends Node2D

signal start_game
signal start_credits

func _ready():
	var _discard = $Buttons/HBox/Start.connect(
		"button_up", self, "emit_signal", ["start_game"])
	_discard = $Buttons/HBox/Credits.connect(
		"button_up", self, "emit_signal", ["start_credits"])

func _process(_delta):
	$Controls/FreezeIndicator.update_sprites(
		clamp($FreezeTimer.get_time_left()-1.0, 0.0, 6.0)
	)
