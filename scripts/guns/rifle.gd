class_name Rifle
extends Gun

func _init():
	super._init(0.5, 150, 2, 13, -0.01, preload("res://sprites/gun/rifle.png"), "rifle")

func shoot():
	for i in range(3):
		send_bullet()
		await get_tree().create_timer(0.1).timeout
