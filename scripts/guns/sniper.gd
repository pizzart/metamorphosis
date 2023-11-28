class_name Sniper
extends Gun

const NAME = "SNIPER RIFLE"
const TEXTURE = preload("res://sprites/weapons/sniper.png")

func _init():
	super._init(20, 1.4, 300, 0.01, 2, 18, -0.001, TEXTURE, NAME)
	bullet_damage = 3

func attack():
	super.attack()
	send_bullet()
