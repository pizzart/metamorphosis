extends Sprite2D

var direction = Vector2.RIGHT
var speed: float = 1
var time: float

func _process(delta):
	global_position += direction * speed * delta
	time += delta
	if time > 100:
		queue_free()
