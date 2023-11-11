extends CharacterBody3D

signal damaged
signal killed
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var health: int = 30

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = get_tree().get_first_node_in_group("player_3d")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	velocity = position.direction_to(player.position) * Vector3(1, 0, 1) * SPEED

	move_and_slide()

func damage(dmg: int):
	health -= dmg
	damaged.emit()
	if health <= 0:
		killed.emit()
		queue_free()
