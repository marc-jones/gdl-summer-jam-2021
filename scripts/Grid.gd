extends Node2D

var tile_size

var texture_array
var panel_height = 16
var panel_width = 24

var size

var sprite_references = []

func init(input_texture_array):
	texture_array = input_texture_array
	tile_size = texture_array[0].get_size()
	size = Vector2(0, 0)
	initialise_panel()

func initialise_panel():
	for col_idx in range(panel_width):
		sprite_references.append([])
		for row_idx in range(panel_height):
			var new_sprite = add_random_tile(Vector2(col_idx, row_idx))
			size += new_sprite.texture.get_size()
			sprite_references[col_idx].append(new_sprite)
	size.x /= panel_height
	size.y /= panel_width

func add_random_tile(grid_position):
	return(add_tile_texture(grid_position, texture_array[randi() % len(texture_array)]))

func add_tile_texture(grid_position, texture):
	var sprite = Sprite.new()
	sprite.texture = texture
	return(add_tile_sprite(grid_position, sprite))

func add_tile_sprite(grid_position, sprite):
	var new_sprite = sprite.duplicate()
	new_sprite.name = str(grid_position.x) + '_' + str(grid_position.y)
	new_sprite.position = get_pixel_position(grid_position)
	$Tiles.add_child(new_sprite)
	return(new_sprite)

func get_pixel_position(grid_position):
	return(Vector2(
		(grid_position.x - (panel_width - 1) / 2.0) * tile_size.x,
		(grid_position.y - (panel_height - 1) / 2.0) * tile_size.y))

func test_grid_position_in_range(grid_position):
	return((0 <= grid_position.x and grid_position.x < panel_width) and
		(0 <= grid_position.y and grid_position.y < panel_height))

func get_grid_position(pixel_position):
	return(Vector2(
		round(pixel_position.x / tile_size.x + (panel_width - 1) / 2.0),
		round(pixel_position.y / tile_size.y + (panel_height - 1) / 2.0)))

func set_texture_of_tile(grid_position, input_texture):
	sprite_references[grid_position.x][grid_position.y].queue_free()
	var new_sprite = add_tile_texture(grid_position, input_texture)
	sprite_references[grid_position.x][grid_position.y] = new_sprite

func set_tile(grid_position, input_tile):
	sprite_references[grid_position.x][grid_position.y].queue_free()
	var new_tile = add_tile_sprite(grid_position, input_tile)
	sprite_references[grid_position.x][grid_position.y] = new_tile

func get_all_neighbours(grid_position):
	var dirs = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	var return_array = []
	for dir in dirs:
		if test_grid_position_in_range(grid_position + dir):
			return_array.append(grid_position + dir)
	return(return_array)

func set_tile_modulate(grid_position, colour):
	sprite_references[grid_position.x][grid_position.y].set_modulate(colour)
