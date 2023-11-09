class_name Shotgun
extends Gun

const NAME = "SHOTGUN"
const TEXTURE = preload("res://sprites/weapon/shotgun.png")

func _init():
	super._init(30, 1.0, 150, 0.35, 2, 10, -0.3, TEXTURE, NAME)

func attack():
	super.attack()
	for i in range(6):
		send_bullet()
