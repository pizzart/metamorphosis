class_name Boss1
extends Foe

const SPEED = 50.0

func _init():
	super._init()
	health = 50

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED

	move_and_slide()
