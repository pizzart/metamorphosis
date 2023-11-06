class_name Pistol
extends Gun

const NAME = "PISTOL"
const TEXTURE = preload("res://sprites/weapon/pistol.png")

func _init():
	super._init(20, 0.2, 50, 0.01, 1, 8, -0.01, TEXTURE, NAME)

func attack():
	super.attack()
	send_bullet()
