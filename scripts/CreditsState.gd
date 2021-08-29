extends Node2D

signal quit

func _ready():
	var _discard = $Buttons/HBox/Menu.connect(
		"button_up", self, "emit_signal", ["quit"])

