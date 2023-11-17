class_name Glock
extends Gun

const NAME = "PISTOL"
const TEXTURE = preload("res://sprites/weapons/glock.png")

func _init():
	super._init(25, 0.1, 60, 0.03, 1, 8, -0.01, TEXTURE, NAME)

func attack():
	super.attack()
	send_bullet()
