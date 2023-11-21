class_name Minigun
extends Gun

const NAME = "MACHINE GUN"
const TEXTURE = preload("res://sprites/weapons/minigun.png")

func _init():
	super._init(10, 0.2, 200, 0.15, 3, 15, -0.01, TEXTURE, NAME)

func _process(delta):
	super._process(delta)
	if Input.is_action_pressed("attack") and can_attack_fr() and player.ammo >= ammo_cost:
		attack()

func _input(event):
	pass

func attack():
	super.attack()
	send_bullet()
