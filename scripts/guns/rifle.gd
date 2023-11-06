class_name Rifle
extends Gun

const NAME = "RIFLE"
const TEXTURE = preload("res://sprites/weapon/rifle.png")

func _init():
	super._init(30, 0.5, 100, 0.07, 2, 13, -0.01, TEXTURE, NAME)

func attack():
	super.attack()
	for i in range(3):
		send_bullet()
		await get_tree().create_timer(0.1).timeout
