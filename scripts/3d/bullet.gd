extends Area3D

var velocity: Vector3
var acceleration: Vector3

func _physics_process(delta):
	position += velocity
	velocity += acceleration

func _on_body_entered(body):
	if body.is_in_group("player_3d"):
		body.damage(1)
	queue_free()

func _on_timer_timeout():
	queue_free()
