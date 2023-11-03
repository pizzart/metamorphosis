class_name Gun
extends Node2D

const BULLET = preload("res://scenes/bullet.tscn")
const HAND_SPRITE = preload("res://sprites/hand.png")

var reload_speed: float
var knockback: float
var weight: int
var bullet_speed: float
var bullet_acceleration: float
var can_shoot: bool = true

var timer = Timer.new()

func _init(_reload_speed, _knockback, _weight, _bullet_speed, _bullet_acceleration):
	reload_speed = _reload_speed
	knockback = _knockback
	weight = _weight
	bullet_speed = _bullet_speed
	bullet_acceleration = _bullet_acceleration

func _ready():
	timer.wait_time = reload_speed
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	var sprite = Sprite2D.new()
	sprite.texture = HAND_SPRITE
	add_child(sprite)

func _input(event):
	if event.is_action_pressed("attack") and can_shoot:
		shoot()

func shoot():
	send_bullet()

func send_bullet():
	var bullet = BULLET.instantiate()
	bullet.velocity = global_position.direction_to(get_global_mouse_position()) * bullet_speed
	bullet.acceleration = bullet_acceleration
	bullet.global_position = global_position
	bullet.set_by_player()
	get_parent().get_parent().add_child(bullet)
	
	can_shoot = false
	timer.start(reload_speed)

func _on_timer_timeout():
	can_shoot = true
