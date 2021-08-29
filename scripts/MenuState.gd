extends Node2D

signal start_game
signal start_credits

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	var _discard = $Buttons/HBox/Start.connect(
		"button_up", self, "start_game")
	_discard = $Buttons/HBox/Credits.connect(
		"button_up", self, "start_credits")

func _process(_delta):
	$Controls/FreezeIndicator.update_sprites(
		clamp($FreezeTimer.get_time_left()-1.0, 0.0, 6.0)
	)

func start_game():
	audio.play_sound("blip")
	emit_signal("start_game")

func start_credits():
	audio.play_sound("blip")
	emit_signal("start_credits")
