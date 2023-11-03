extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")
var movement_speed: float = 80.0
var RNG = RandomNumberGenerator.new()
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	call_deferred("actor_setup")

func _physics_process(delta):
	var new_velocity: Vector2
#	for i in range(get_slide_collision_count()):
#		new_velocity += get_slide_collision(i).get_collider_velocity() / 4
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		new_velocity = (next_path_position - global_position).normalized() * movement_speed
		velocity = lerp(velocity, new_velocity, 0.1)
	else:
		velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()

func actor_setup():
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_navigation_timer_timeout():
	$NavigationTimer.start(RNG.randf_range(4, 9))
	set_movement_target(get_close_position())
	while not navigation_agent.is_target_reachable():
		set_movement_target(get_close_position())

func get_close_position():
	return global_position + Vector2(RNG.randfn(0, 30), RNG.randfn(0, 30))

func die():
	queue_free()

func _on_shoot_timer_timeout():
	var bullet = BULLET.instantiate()
	bullet.velocity = global_position.direction_to(player.global_position) * 5
	bullet.acceleration = -0.02
	bullet.global_position = global_position
	bullet.set_by_enemy()
	get_parent().add_child(bullet)
