class_name Policeman
extends ShootingEnemy

func _init():
	super._init(3, 2, 9, 70, 70, MAX_DISTANCE)
	
	sprite.sprite_frames = preload("res://resources/frames/policeman.tres")
	sprite.autoplay = "idle"

func shoot():
	for i in range(3):
		var bullet = Bullet.new(global_position.direction_to(player.global_position).rotated(rng.randfn(0, 0.5)) * 5, -0.02, false)
		bullet.global_position = global_position
		get_parent().add_child(bullet)
