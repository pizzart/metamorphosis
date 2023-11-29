class_name Rat
extends CloseEnemy

var attacking: bool
var attacking_time: float

func _init():
	super._init(1, 1, 5, 120, 300)
	
	collision_shape.shape.size *= 0.3
	area_shape.shape.size *= 0.5
	
	sprite.sprite_frames = preload("res://resources/frames/rat.tres")
	sprite.autoplay = "idle"

func _process(delta):
	if attacking:
		attacking_time += delta
		if attacking_time - floor(attacking_time) >= 0.2: # fucked up
			set_movement_target(player.global_position + Vector2(rng.randf_range(-20, 20), rng.randf_range(-20, 20)))
			attacking_time = ceil(attacking_time)
		
		if attacking_time >= 20:
			stop_attacking()

func stop_attacking():
	sprite.animation = "idle"
	speed = walk_speed
	area.monitoring = false
	nav_timer.paused = false
#	set_collision_mask_value(1, true)
	attacking_time = 0
	attacking = false

func hit(damage: int, force: Vector2):
	if attacking:
		stop_attacking()
	super.hit(damage, force)
	if attacking:
		set_movement_target(global_position + force.normalized() * 30)
		await get_tree().create_timer(STUN_TIME).timeout

func _on_attack_timer_timeout():
	attack_timer.start(rng.randf_range(3, 8))
	
	attack_audio.play()
	set_movement_target(player.global_position)
	sprite.animation = "attack"
	speed = attack_speed
	area.monitoring = true
	nav_timer.paused = true
#	set_collision_mask_value(1, false)
	attacking = true
