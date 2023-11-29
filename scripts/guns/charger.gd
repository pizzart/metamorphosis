class_name Charger
extends Gun

const NAME = "CHARGER"
const TEXTURE = preload("res://sprites/weapons/charger.png")
const CHARGE_TIME = 5.0
const BULLET_POINT = Vector2(21, 0)
var charge: float
var bullet_sprite = Sprite2D.new()

func _init():
	super._init(90, 2.0, 1000, 0.1, 3, 8, -0.03, TEXTURE, NAME)
	bullet_damage = 5
	bullet_sprite.texture = preload("res://sprites/bullet.png")
	bullet_sprite.scale = Vector2.ZERO
	bullet_sprite.position = BULLET_POINT
	sprite.add_child(bullet_sprite)

func _process(delta):
	super._process(delta)
	bullet_sprite.scale = Vector2.ONE * 2 * (charge / CHARGE_TIME)
	if charge >= CHARGE_TIME:
		bullet_sprite.modulate = Color(2, 2, 2)
	if Input.is_action_pressed("attack") and can_attack_fr() and player.ammo >= ammo_cost:
		charge = clampf(charge + delta, 0, CHARGE_TIME)
	elif Input.is_action_just_released("attack") and charge >= CHARGE_TIME:
		attack()
		charge = 0
	else:
		charge = 0
#		attack()

func _input(event):
	if event.is_action_pressed("attack") and (not can_attack_fr() or player.ammo < ammo_cost) and is_equipped:
		player.change_emotion(Player.Emotion.Blood)
		error_audio.play()
#	if event.is_action_released("attack") and charge >= CHARGE_TIME:
#		attack()

func attack():
	super.attack()
	send_bullet()

func send_bullet():
	var bullet = Bullet.new(direction.rotated(rng.randfn(0, spread)) * bullet_speed, bullet_acceleration, true)
	bullet.damage = bullet_damage
	bullet.piercing = true
	bullet.scale = Vector2(3, 3)
	bullet.global_position = global_position
	player.get_parent().add_child(bullet)
	
	offset_position = OFFSET / 3
	player.knockback(-direction * knockback)
