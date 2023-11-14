class_name Enemy
extends Foe

const BULLET = preload("res://scenes/bullet.tscn")

const DROP_CHANCE = 0.02
const STUN_TIME = 0.2
const MAX_DISTANCE = 300

var movement_speed: float = 80.0

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var nav_timer = $NavigationTimer
@onready var shoot_timer = $ShootTimer

func _init():
	health = 3

func _ready():
	call_deferred("actor_setup")
	nav_timer.start(rng.randf_range(2, 9))

func _physics_process(delta):
	var new_velocity: Vector2
#	for i in range(get_slide_collision_count()):
#		new_velocity += get_slide_collision(i).get_collider_velocity() / 4
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		new_velocity = (next_path_position - global_position).normalized() * movement_speed
	velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()
	
	shoot_timer.paused = global_position.distance_to(player.global_position) > MAX_DISTANCE
	$AnimatedSprite2D.speed_scale = velocity.length() / movement_speed
	
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true

func actor_setup():
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_navigation_timer_timeout():
	nav_timer.start(rng.randf_range(2, 9))
	set_movement_target(get_close_position())
#	while not navigation_agent.is_target_reachable():
#		set_movement_target(get_close_position())

func get_close_position():
	return global_position + Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30))

func hit(damage: int, force: Vector2):
	health -= damage
	if health <= 0:
		die()
	
	velocity += force
	
	shoot_timer.paused = true
	await get_tree().create_timer(STUN_TIME).timeout
	shoot_timer.paused = false

func die():
	if rng.randf() <= DROP_CHANCE:
		var coin = CoinPickup.new()
		coin.global_position = global_position
		get_parent().call_deferred("add_child", coin)
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()

func _on_shoot_timer_timeout():
	shoot_timer.start(rng.randf_range(2, 5))
	var bullet = Bullet.new(global_position.direction_to(player.global_position) * 5, -0.02, false)
	bullet.global_position = global_position
	get_parent().add_child(bullet)
