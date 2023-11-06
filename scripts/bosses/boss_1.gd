extends CharacterBody2D

const SPEED = 50.0
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * SPEED

	move_and_slide()
