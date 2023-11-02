extends Area2D

var velocity: Vector2
var acceleration: float
var acceleration_accel: float = 0

func _physics_process(delta):
	position += velocity
	rotation = velocity.angle()
	velocity.x -= acceleration
	velocity.y -= acceleration
	acceleration -= acceleration_accel
	if velocity.length() <= 0.01:
		queue_free()

func set_by_player():
	set_collision_mask_value(2, true)

func set_by_enemy():
	set_collision_mask_value(1, true)

func _on_body_entered(body):
	# reads mask layer 2: enemy
	queue_free()
