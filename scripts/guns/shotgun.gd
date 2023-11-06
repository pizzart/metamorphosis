class_name Shotgun
extends Gun

const NAME = "SHOTGUN"
const TEXTURE = preload("res://sprites/weapon/rifle.png")

func _init():
	super._init(50, 0.5, 150, 0.5, 2, 10, -0.3, TEXTURE, NAME)

func attack():
	super.attack()
	for i in range(6):
		send_bullet()
