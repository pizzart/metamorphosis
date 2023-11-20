class_name ShootingEnemy
extends Enemy

const MAX_DISTANCE = 300

func shoot():
	pass

func _on_attack_timer_timeout():
	attack_timer.start(rng.randf_range(3, 5))
	
	set_movement_target(player.global_position)
	sprite.animation = "attack"
	shoot()
	await get_tree().create_timer(0.5).timeout
	sprite.animation = "idle"
