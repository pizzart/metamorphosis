class_name Boss3
extends Foe

signal killed

const SPEED = 40.0

func _init():
	health = 20

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED

	move_and_slide()

func hit(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	killed.emit()
	queue_free()
