class_name CloseEnemy
extends Enemy

const MAX_DISTANCE = 400

var area: Area2D

func _init(_health: int, _shuffle_min: float, _shuffle_max: float, _walk_speed: float, _attack_speed: float):
	super._init(_health, _shuffle_min, _shuffle_max, _walk_speed, _attack_speed, MAX_DISTANCE)
	
	area = Area2D.new()
	var area_shape = CollisionShape2D.new()
	area_shape.shape = RectangleShape2D.new()
	area_shape.shape.size = collision_shape.shape.size * 1.5
	area.monitoring = false
	area.set_collision_layer_value(1, false)
	area.add_child(area_shape)
	area.body_entered.connect(_on_attack_entered)
	add_child(area)

func _ready():
	actor_setup.call_deferred()
	nav_timer.start(rng.randf_range(2, 9))

func _physics_process(_delta):
	var new_velocity: Vector2
	
	if not navigation_agent.is_navigation_finished():
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		new_velocity = (next_path_position - global_position).normalized() * speed
	velocity = lerp(velocity, new_velocity, 0.1)

	move_and_slide()
	
	attack_timer.paused = global_position.distance_to(player.global_position) > MAX_DISTANCE
	
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
	super.hit(damage, force * 2)

func _on_attack_entered(body):
	body.hit(1, global_position.direction_to(body.global_position))
