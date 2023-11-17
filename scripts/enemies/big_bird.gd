class_name BigBird
extends Foe

const DROP_CHANCE = 0.02
const STUN_TIME = 0.2
const WALK_SPEED = 90
const MAX_DISTANCE = 300

var navigation_agent: NavigationAgent2D
var nav_timer: Timer
var attack_timer: Timer
var collision_shape: CollisionShape2D
var sprite: AnimatedSprite2D

func _init():
	health = 3
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
	set_collision_mask_value(4, true)
	
	collision_shape = CollisionShape2D.new()
	collision_shape.shape = RectangleShape2D.new()
	
	navigation_agent = NavigationAgent2D.new()
	navigation_agent.path_desired_distance = 5
	navigation_agent.target_desired_distance = 3
	navigation_agent.path_max_distance = 50
	
	nav_timer = Timer.new()
	nav_timer.wait_time = 5
	
	attack_timer = Timer.new()
	attack_timer.wait_time = 3
	attack_timer.autostart = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	var shadow = Sprite2D.new()
	shadow.texture = preload("res://sprites/shadow.png")
	shadow.position = Vector2(0, 9)
	
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = preload("res://resources/frames/bird.tres")
	sprite.animation = "idle"
	sprite.modulate = Color.RED
	
	add_child(collision_shape)
	add_child(navigation_agent)
	add_child(nav_timer)
	add_child(attack_timer)
	add_child(shadow)
	add_child(sprite)
	
	add_to_group("enemy")

func _ready():
	call_deferred("actor_setup")
	nav_timer.start(rng.randf_range(2, 9))

func _physics_process(delta):
	var new_velocity: Vector2
#	for i in range(get_slide_collision_count()):
#		new_velocity += get_slide_collision(i).get_collider_velocity() / 4
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		new_velocity = (next_path_position - global_position).normalized() * WALK_SPEED
	velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()
	
	attack_timer.paused = global_position.distance_to(player.global_position) > MAX_DISTANCE
	sprite.speed_scale = velocity.length() / WALK_SPEED
	
	if velocity.x > 0:
		sprite.flip_h = false
	if velocity.x < 0:
		sprite.flip_h = true

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
	
	attack_timer.paused = true
	await get_tree().create_timer(STUN_TIME).timeout
	attack_timer.paused = false

func die():
	if rng.randf() <= DROP_CHANCE:
		var coin = CoinPickup.new()
		coin.global_position = global_position
		get_parent().call_deferred("add_child", coin)
	collision_shape.set_deferred("disabled", true)
	queue_free()

func _on_attack_timer_timeout():
	attack_timer.start(rng.randf_range(3, 5))
	
	set_movement_target(player.global_position)
	sprite.animation = "attack"
	
	var bullet = Bullet.new(global_position.direction_to(player.global_position) * 5, -0.02, false)
	bullet.global_position = global_position
	get_parent().add_child(bullet)
	
	await get_tree().create_timer(0.3).timeout
	sprite.animation = "idle"
