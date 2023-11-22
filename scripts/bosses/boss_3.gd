class_name Boss3
extends Foe

const SPEED = 40.0

func _init():
	super._init()
	health = 20

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED

	move_and_slide()

func hit(damage: int, force: Vector2):
	health -= damage
	if health <= 0:
		die()

func die():
	super.die()
	queue_free()
