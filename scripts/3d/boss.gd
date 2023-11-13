extends CharacterBody3D

signal damaged
signal killed

const BULLET = preload("res://scenes/3d/bullet.tscn")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var health: int = 30

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var player = get_tree().get_first_node_in_group("player_3d")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	var horizontal_velo = position.direction_to(player.position) * SPEED
	velocity.x = horizontal_velo.x
	velocity.z = horizontal_velo.z

	move_and_slide()

func damage(dmg: int):
	health -= dmg
	damaged.emit()
	if health <= 0:
		killed.emit()
		queue_free()

func attack_1():
	for i in range(3):
		var bullet = BULLET.instantiate()
		bullet.velocity = global_position.direction_to(player.global_position) * 0.6
		bullet.acceleration = -global_position.direction_to(player.global_position) * 0.001
		get_parent().add_child(bullet)
		bullet.global_position = global_position
		await get_tree().create_timer(0.05).timeout

func _on_attack_timer_timeout():
	attack_1()
