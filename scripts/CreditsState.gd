extends Node2D

signal quit

onready var audio = get_tree().get_root().get_node("Audio")

func _ready():
	var _discard = $Buttons/HBox/Menu.connect(
		"button_up", self, "quit")

func quit():
	audio.play_sound("blip")
	emit_signal("quit")
