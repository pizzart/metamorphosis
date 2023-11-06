class_name Gun
extends Weapon

const BULLET = preload("res://scenes/bullet.tscn")
const HAND_SPRITE = preload("res://sprites/hand.png")

var ammo_cost: int
var spread: float
var bullet_speed: float
var bullet_acceleration: float

func _init(_ammo_cost: float, _reload_speed: float, _knockback: float, _spread: float, _weight: int, \
			_bullet_speed: float, _bullet_acceleration: float, _texture: Texture2D, _gun_name: String):
	ammo_cost = _ammo_cost
	spread = _spread
	bullet_speed = _bullet_speed
	bullet_acceleration = _bullet_acceleration
	super._init(_reload_speed, _weight, _knockback, _texture, _gun_name)
	is_equipped = true

func _input(event):
	if event.is_action_pressed("attack") and can_attack and is_equipped and player.can_move:
		if player.ammo >= ammo_cost:
			attack()

func attack():
	super.attack()
	player.ammo -= ammo_cost

func send_bullet():
	var bullet = Bullet.new(player.global_position.direction_to(get_global_mouse_position()).rotated(rng.randfn(0, spread)) * bullet_speed, bullet_acceleration, true)
	bullet.global_position = global_position
	player.get_parent().add_child(bullet)
	
	offset_position = OFFSET / 4
	player.knockback(-player.global_position.direction_to(get_global_mouse_position()) * knockback)
