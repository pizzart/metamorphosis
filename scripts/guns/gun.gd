class_name Gun
extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")
const HAND_SPRITE = preload("res://sprites/hand.png")
const OFFSET = 20

var ammo_cost: int
var reload_speed: float
var knockback: float
var weight: int
var bullet_speed: float
var bullet_acceleration: float
var texture: Texture2D
var can_shoot: bool = true
var offset_position: float = OFFSET
var gun_name: String = "gun"

var timer = Timer.new()
var sprite = Sprite2D.new()

@onready var player: Player = get_parent()

func _init(_ammo_cost, _reload_speed, _knockback, _weight, _bullet_speed, _bullet_acceleration, _texture, _gun_name):
	ammo_cost = _ammo_cost
	reload_speed = _reload_speed
	knockback = _knockback
	weight = _weight
	bullet_speed = _bullet_speed
	bullet_acceleration = _bullet_acceleration
	texture = _texture
	gun_name = _gun_name

func _ready():
	timer.wait_time = reload_speed
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	sprite.texture = texture
	add_child(sprite)

func _process(delta):
	offset_position = lerpf(offset_position, OFFSET, 0.05)
	position = (get_global_mouse_position() - player.global_position).limit_length(offset_position)
	sprite.rotation = player.global_position.direction_to(get_global_mouse_position()).angle()
	sprite.flip_v = sprite.rotation < -PI / 2 or sprite.rotation > PI / 2

func _input(event):
	if event.is_action_pressed("attack") and can_shoot:
		if player.ammo > ammo_cost:
			player.ammo -= ammo_cost
			shoot()

func shoot():
	send_bullet()

func send_bullet():
	var bullet = BULLET.instantiate()
	bullet.velocity = player.global_position.direction_to(get_global_mouse_position()) * bullet_speed
	bullet.acceleration = bullet_acceleration
	bullet.global_position = global_position
	bullet.set_by_player()
	player.get_parent().add_child(bullet)
	
	can_shoot = false
	timer.start(reload_speed)
	
	offset_position = 5
	player.knockback(-player.global_position.direction_to(get_global_mouse_position()) * knockback)

func _on_timer_timeout():
	can_shoot = true