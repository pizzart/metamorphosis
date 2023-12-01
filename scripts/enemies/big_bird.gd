class_name BigBird
extends ShootingEnemy

func _init():
	super._init(3, 1, 6, 90, 90, MAX_DISTANCE)
	
	sprite.sprite_frames = preload("res://resources/frames/big_bird.tres")
	sprite.autoplay = "idle"

func shoot():
	var bullet = Bullet.new(global_position.direction_to(player.global_position).rotated(rng.randfn(0, 0.5)) * 5, -0.02, false)
	bullet.global_position = global_position
	get_parent().add_child(bullet)
