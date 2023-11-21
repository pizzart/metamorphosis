extends Camera2D

var decay = 0.8
var max_offset = Vector2(40, 40)

var trauma: float = 0
var trauma_power = 1.5

func _ready():
	randomize()

func _process(delta):
	offset = (get_global_mouse_position() - get_parent().global_position) / 4
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		offset += shake()

func add_trauma(amount: float):
	trauma = min(trauma + amount, 0.4)

func shake():
	var amount = pow(trauma, trauma_power)
#	rotation = max_roll * amount * rand_range(-1, 1)
	return Vector2(max_offset.x * amount * randf_range(-1, 1), max_offset.y * amount * randf_range(-1, 1))

func override_trauma(amount: float):
	trauma = amount
