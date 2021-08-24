extends Node2D

var current_path = [
	Vector2(4, 5),
	Vector2(4, 6),
	Vector2(4, 7),
	Vector2(5, 7),
	Vector2(6, 7),
	Vector2(6, 6),
	Vector2(7, 6),
	Vector2(7, 7),
	Vector2(7, 8),
	Vector2(6, 8)
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

func _ready():
	pass

func init(grid_ref):
	grid = grid_ref

func refresh_trail():
	for old_node in get_children():
		old_node.queue_free()
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

func add_new_position(diff):
	var new_position = current_path.back() + diff
	if (not new_position in current_path and
		grid.test_grid_position_in_range(new_position)):
		current_path.append(new_position)
		refresh_trail()
