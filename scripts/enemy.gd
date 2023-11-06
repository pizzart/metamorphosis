extends CharacterBody2D

const BULLET = preload("res://scenes/bullet.tscn")
const DROP_CHANCE = 0.02
var movement_speed: float = 80.0
var health: int = 3
var RNG = RandomNumberGenerator.new()
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	call_deferred("actor_setup")
	$NavigationTimer.start(RNG.randf_range(2, 9))

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
	$NavigationTimer.start(RNG.randf_range(2, 9))
	set_movement_target(get_close_position())
#	while not navigation_agent.is_target_reachable():
#		set_movement_target(get_close_position())

func get_close_position():
	return global_position + Vector2(RNG.randf_range(-30, 30), RNG.randf_range(-30, 30))

func hit(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	if RNG.randf() <= DROP_CHANCE:
		var coin = CoinPickup.new()
		coin.global_position = global_position
		get_parent().add_child(coin)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()

func _on_shoot_timer_timeout():
	$ShootTimer.start(RNG.randf_range(2, 5))
	var bullet = Bullet.new(global_position.direction_to(player.global_position) * 5, -0.02, false)
	bullet.global_position = global_position
	get_parent().add_child(bullet)
