extends Node2D

var current_path = [
]

var texture_dict = {
	"vertical": preload("res://assets/sprites/indicator/vertical.png"),
	"horizontal": preload("res://assets/sprites/indicator/horizontal.png"),
	"arrow_n": preload("res://assets/sprites/indicator/arrow_n.png"),
	"arrow_e": preload("res://assets/sprites/indicator/arrow_e.png"),
	"arrow_w": preload("res://assets/sprites/indicator/arrow_w.png"),
	"arrow_s": preload("res://assets/sprites/indicator/arrow_s.png"),
	"corner_ne": preload("res://assets/sprites/indicator/corner_ne.png"),
	"corner_nw": preload("res://assets/sprites/indicator/corner_nw.png"),
	"corner_se": preload("res://assets/sprites/indicator/corner_se.png"),
	"corner_sw": preload("res://assets/sprites/indicator/corner_sw.png"),
	"start_n": preload("res://assets/sprites/indicator/start_n.png"),
	"start_e": preload("res://assets/sprites/indicator/start_e.png"),
	"start_w": preload("res://assets/sprites/indicator/start_w.png"),
	"start_s": preload("res://assets/sprites/indicator/start_s.png")
}

var grid
var wall_positions
var active = true

func _ready():
	pass

func init(grid_ref, wall_positions_ref):
	grid = grid_ref
	wall_positions = wall_positions_ref

func refresh_trail():
	for old_node in get_children():
		old_node.queue_free()
	if len(current_path) < 2:
		return
	for idx in range(len(current_path)):
		var prev_diff = null
		var next_diff = null
		if idx < len(current_path)-1:
			next_diff = current_path[idx+1] - current_path[idx]
		if 0 < idx:
			prev_diff = current_path[idx] - current_path[idx-1]
		if prev_diff == null:
			match next_diff:
				Vector2(1, 0):
					add_section("start_e", current_path[idx])
				Vector2(-1, 0):
					add_section("start_w", current_path[idx])
				Vector2(0, 1):
					add_section("start_s", current_path[idx])
				Vector2(0, -1):
					add_section("start_n", current_path[idx])
		elif next_diff == null:
			match prev_diff:
				Vector2(1, 0):
					add_section("arrow_w", current_path[idx])
				Vector2(-1, 0):
					add_section("arrow_e", current_path[idx])
				Vector2(0, 1):
					add_section("arrow_n", current_path[idx])
				Vector2(0, -1):
					add_section("arrow_s", current_path[idx])
		else:
			if abs(next_diff.x) == 1 and abs(prev_diff.x) == 1:
				add_section("horizontal", current_path[idx])
			elif abs(next_diff.y) == 1 and abs(prev_diff.y) == 1:
				add_section("vertical", current_path[idx])
			else:
				if ((prev_diff.x == 1 and next_diff.y == -1) or
					(prev_diff.y == 1 and next_diff.x == -1)):
					add_section("corner_nw", current_path[idx])
				elif ((prev_diff.x == 1 and next_diff.y == 1) or
					(prev_diff.y == -1 and next_diff.x == -1)):
					add_section("corner_sw", current_path[idx])
				elif ((prev_diff.x == -1 and next_diff.y == -1) or
					(prev_diff.y == 1 and next_diff.x == 1)):
					add_section("corner_ne", current_path[idx])
				elif ((prev_diff.x == -1 and next_diff.y == 1) or
					(prev_diff.y == -1 and next_diff.x == 1)):
					add_section("corner_se", current_path[idx])

func add_section(type, grid_position):
	var sprite = Sprite.new()
	sprite.set_texture(texture_dict[type])
	sprite.set_position(grid.get_pixel_position(grid_position))
	add_child(sprite)

func input(diff):
	if not active:
		return
	var new_position = current_path.back() + diff
	if len(current_path) > 1 and new_position == current_path[-2]:
		current_path.pop_back()
	elif (not new_position in current_path and
		grid.test_grid_position_in_range(new_position) and
		not new_position in wall_positions):
		current_path.append(new_position)
	refresh_trail()

func start_new_path(start_grid_position):
	current_path = [start_grid_position]
	refresh_trail()

func set_active(input_bool):
	active = input_bool

func get_current_path():
	return(current_path)
