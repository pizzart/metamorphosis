class_name Worm
extends CloseEnemy

var attacking: bool
var attacking_time: float

func _init():
	super._init(1, 2, 5, 30, 7)
	
	sprite.sprite_frames = preload("res://resources/frames/worm.tres")
	sprite.autoplay = "idle"

func _process(delta):
	if velocity.length_squared() > 1:
		sprite.speed_scale = 1
	else:
		sprite.speed_scale = 0

func _on_attack_timer_timeout():
	attack_timer.start(rng.randf_range(1, 3))
	
	sprite.animation = "attack"
	await get_tree().create_timer(0.2).timeout
	set_movement_target(player.global_position)
	speed = attack_speed
	area.monitoring = true
	nav_timer.paused = true
	attack_audio.play()
	await get_tree().create_timer(0.22).timeout
	speed = walk_speed
	area.monitoring = false
	nav_timer.paused = false
	await get_tree().create_timer(0.2).timeout
	sprite.play("idle")
