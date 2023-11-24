class_name Minigun
extends Gun

const NAME = "MACHINE GUN"
const TEXTURE = preload("res://sprites/weapons/minigun.png")

func _init():
	super._init(10, 0.2, 250, 0.25, 3, 15, -0.01, TEXTURE, NAME)

func _process(delta):
	super._process(delta)
	if Input.is_action_pressed("attack") and can_attack_fr() and player.ammo >= ammo_cost:
		attack()

func _input(event):
	if event.is_action_pressed("attack") and (not can_attack_fr() or player.ammo < ammo_cost) and is_equipped:
		player.change_emotion(Player.Emotion.Blood)
		error_audio.play()

func attack():
	super.attack()
	send_bullet()
