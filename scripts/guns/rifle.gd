class_name Rifle
extends Gun

const NAME = "RIFLE"
const TEXTURE = preload("res://sprites/weapons/rifle.png")

func _init():
	super._init(20, 0.5, 100, 0.07, 2, 13, -0.01, TEXTURE, NAME)

func attack():
	super.attack()
	for i in range(3):
		if i != 0:
			audio.play()
		send_bullet()
		await get_tree().create_timer(0.1).timeout
