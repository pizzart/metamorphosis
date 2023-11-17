class_name FlyingBird
extends Foe

const DROP_CHANCE = 0.02
const STUN_TIME = 0.2
const MAX_DISTANCE = 400
const WALK_SPEED = 100
const ATTACK_SPEED = 0

var speed: float = WALK_SPEED

var navigation_agent: NavigationAgent2D
var nav_timer: Timer
var attack_timer: Timer
var collision_shape: CollisionShape2D
var sprite: AnimatedSprite2D
var area: Area2D

func _init():
	health = 3
	
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(2, true)
#	set_collision_mask_value(4, true)
	
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
	
	area = Area2D.new()
	var area_shape = CollisionShape2D.new()
	area_shape.shape = RectangleShape2D.new()
	area_shape.shape.size = collision_shape.shape.size * 1.5
	area.monitoring = false
	area.set_collision_layer_value(1, false)
	area.add_child(area_shape)
	area.body_entered.connect(_on_attack_entered)
	
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = preload("res://resources/frames/flying_bird.tres")
	sprite.animation = "idle"
	
	add_child(collision_shape)
	add_child(navigation_agent)
	add_child(nav_timer)
	add_child(attack_timer)
	add_child(shadow)
	add_child(sprite)
	add_child(area)
	
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
		new_velocity = (next_path_position - global_position).normalized() * speed
	velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()
	
	attack_timer.paused = global_position.distance_to(player.global_position) > MAX_DISTANCE
	sprite.speed_scale = velocity.length() / speed
	
	if velocity.x > 0:
		sprite.flip_h = false
	if velocity.x < 0:
		sprite.flip_h = true

func stop_attacking():
	sprite.animation = "idle"
	speed = WALK_SPEED
	area.monitoring = false
	nav_timer.paused = false
#	set_collision_mask_value(1, true)

func actor_setup():
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_navigation_timer_timeout():
	nav_timer.start(rng.randf_range(1, 3))
	set_movement_target(get_close_position())
#	while not navigation_agent.is_target_reachable():
#		set_movement_target(get_close_position())

func get_close_position():
	return global_position + Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30))

func hit(damage: int, force: Vector2):
	health -= damage
	if health <= 0:
		die()
	
	velocity += force * 2
	
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
	attack_timer.start(rng.randf_range(4, 7))
	
	await get_tree().create_timer(0.2).timeout
	set_movement_target(player.global_position)
#	sprite.animation = "attack"
	speed = ATTACK_SPEED
	area.monitoring = true
	nav_timer.paused = true
	await get_tree().create_timer(0.2).timeout
#	sprite.animation = "attack"
	speed = WALK_SPEED
	area.monitoring = false
	nav_timer.paused = false

func _on_attack_entered(body):
	body.hit(1)
