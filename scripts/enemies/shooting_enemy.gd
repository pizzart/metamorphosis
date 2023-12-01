class_name ShootingEnemy
extends Enemy

const MAX_DISTANCE = 300
var ray = RayCast2D.new()

func _init(_health: int, _shuffle_min: float, _shuffle_max: float, _walk_speed: float, _attack_speed: float, _max_distance: float):
	super._init(_health, _shuffle_min, _shuffle_max, _walk_speed, _attack_speed, _max_distance)
	set_collision_mask_value(4, true)
	set_collision_mask_value(5, true)
	set_collision_mask_value(6, true)
	ray.set_collision_mask_value(1, false)
	ray.set_collision_mask_value(5, true)
	ray.set_collision_mask_value(6, true)
	add_child(ray)

func _physics_process(delta):
	super._physics_process(delta)
	if global_position.distance_to(player.global_position) <= max_distance:
		ray.target_position = to_local(player.global_position)
	attack_timer.paused = global_position.distance_to(player.global_position) > max_distance or ray.is_colliding()

func shoot():
	pass

func _on_attack_timer_timeout():
	var time = rng.randf_range(3, 5)
	attack_timer.start(time)
	offload_audio(time - 0.58)
	
	set_movement_target(player.global_position + Vector2(rng.randf_range(-128, 128), rng.randf_range(-128, 128)))
	sprite.play("attack")
	attack_audio.play()
	shoot()
	await get_tree().create_timer(0.5).timeout
	sprite.play("idle")

func offload_audio(time: float):
	await get_tree().create_timer(time).timeout
	prepare_audio.play()
