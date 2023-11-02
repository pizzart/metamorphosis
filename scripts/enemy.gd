extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")
var movement_speed: float = 100.0
var RNG = RandomNumberGenerator.new()
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	call_deferred("actor_setup")

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()

	var new_velocity: Vector2 = next_path_position - global_position
	new_velocity = new_velocity.normalized() * movement_speed

	velocity = new_velocity
	move_and_slide()

func actor_setup():
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_navigation_timer_timeout():
	$NavigationTimer.start(RNG.randf_range(4, 9))
	set_movement_target(global_position + Vector2(RNG.randfn(0, 30), RNG.randfn(0, 30)))

func _on_shoot_timer_timeout():
	var bullet = BULLET.instantiate()
	bullet.velocity = global_position.direction_to(player.global_position) * 7
	bullet.acceleration = -0.012
	bullet.global_position = global_position
	bullet.set_by_enemy()
	get_parent().add_child(bullet)
