extends Node2D

func _ready():
	pass

func update_sprites(current_time):
	for child in get_children():
		child.hide()
	get_node(str(ceil(current_time))).show()
