class_name Enemy
extends Foe

const DROP_CHANCE = 0.1
const HEALTH_DROP_CHANCE = 0.05
const STUN_TIME = 0.2
const CORPSE = preload("res://scenes/corpse.tscn")

var walk_speed: float
var attack_speed: float
var speed: float = walk_speed
var shuffle_min: float = 1
var shuffle_max: float = 3
var max_distance: float = 300

var navigation_agent: NavigationAgent2D
var nav_timer: Timer
var attack_timer: Timer
var collision_shape: CollisionShape2D

func _init(_health: int, _shuffle_min: float, _shuffle_max: float, _walk_speed: float, _attack_speed: float, _max_distance: float):
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
	
	sprite = AnimatedSprite2D.new()
	
	add_child(collision_shape)
	add_child(navigation_agent)
	add_child(nav_timer)
	add_child(attack_timer)
	add_child(shadow)
	add_child(sprite)
	
	add_to_group("enemy")
	
	health = _health
	shuffle_min = _shuffle_min
	shuffle_max = _shuffle_max
	walk_speed = _walk_speed
	attack_speed = _attack_speed
	speed = walk_speed
	max_distance = _max_distance

func _ready():
	actor_setup.call_deferred()
	nav_timer.start(rng.randf_range(2, 9))

func _physics_process(delta):
	var new_velocity: Vector2
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		new_velocity = (next_path_position - global_position).normalized() * speed
	velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()
	
	attack_timer.paused = global_position.distance_to(player.global_position) > max_distance
	
	if velocity.x > 0:
		sprite.flip_h = false
	if velocity.x < 0:
		sprite.flip_h = true

func actor_setup():
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target

func _on_navigation_timer_timeout():
	nav_timer.start(rng.randf_range(shuffle_min, shuffle_max))
	set_movement_target(get_close_position())

func get_close_position():
	return global_position + Vector2(rng.randf_range(-30, 30), rng.randf_range(-30, 30))

func hit(damage: int, force: Vector2):
	health -= damage
	if health <= 0:
		die()
	
	velocity += force * 2
	
	attack_timer.paused = true
	sprite.modulate = Color.RED
	await get_tree().create_timer(STUN_TIME).timeout
	attack_timer.paused = false
	sprite.modulate = Color.WHITE

func die():
	if rng.randf() <= HEALTH_DROP_CHANCE:
		var pack = HealthPickup.new()
		pack.global_position = global_position
		get_parent().add_child.call_deferred(pack)
	elif rng.randf() <= DROP_CHANCE:
		var coin = CoinPickup.new()
		coin.global_position = global_position
		get_parent().add_child.call_deferred(coin)
	collision_shape.set_deferred("disabled", true)
	
	var corpse = CORPSE.instantiate()
	corpse.sprite_frames = sprite.sprite_frames
	corpse.autoplay = "dead"
	corpse.global_position = global_position
	get_parent().add_child(corpse)
	queue_free()

func _on_attack_timer_timeout():
	pass
