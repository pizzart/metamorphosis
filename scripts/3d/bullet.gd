extends Area3D

var velocity: Vector3
var acceleration: Vector3

func _ready():
	look_at(to_global(velocity.normalized()))

func _physics_process(_delta):
	position += velocity
	velocity += acceleration

func _on_body_entered(body):
	if body.is_in_group("player_3d"):
		body.damage(1)
	else:
		set_deferred("monitoring", false)
		velocity = Vector3.ZERO
		acceleration = Vector3.ZERO
		return
	queue_free()

func _on_timer_timeout():
	queue_free()
