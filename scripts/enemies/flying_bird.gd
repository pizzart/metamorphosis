class_name FlyingBird
extends CloseEnemy

func _init():
	super._init(3, 1, 3, 120, 0)
	
	sprite.sprite_frames = preload("res://resources/frames/flying_bird.tres")
	sprite.autoplay = "idle"

func _on_attack_timer_timeout():
	attack_timer.start(rng.randf_range(1, 3))
	
	await get_tree().create_timer(0.2).timeout
	set_movement_target(player.global_position)
#	sprite.animation = "attack"
	sprite.modulate = Color.BLUE
	speed = attack_speed
	area.monitoring = true
	nav_timer.paused = true
	attack_audio.play()
	await get_tree().create_timer(0.2).timeout
#	sprite.animation = "attack"
	sprite.modulate = Color.WHITE
	speed = walk_speed
	area.monitoring = false
	nav_timer.paused = false
