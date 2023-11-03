class_name Rifle
extends Gun

func _init():
	reload_speed = 0.5
	weight = 200
	knockback = 0.1
	bullet_speed = 13
	bullet_acceleration = -0.01

func shoot():
	for i in range(3):
		send_bullet()
		await get_tree().create_timer(0.1).timeout
