class_name Weapon
extends Node2D

const OFFSET = 20
var recharge_speed: float
var weight: int
var knockback: float
var texture: Texture2D
var weapon_name: String = "weapon"

var offset_position: float = OFFSET
var can_attack: bool = true
var is_equipped: bool = false

var timer = Timer.new()
var sprite = Sprite2D.new()
var rng = RandomNumberGenerator.new()

@onready var player: Player = get_parent()

func _init(_recharge_speed: float, _weight: int, _knockback: float, _texture: Texture2D, _weapon_name: String):
	recharge_speed = _recharge_speed
	weight = _weight
	knockback = _knockback
	texture = _texture
	weapon_name = _weapon_name
	
	rng.randomize()
	timer.wait_time = recharge_speed
	timer.timeout.connect(_on_timer_timeout)
	sprite.texture = texture
	add_child(timer)
	add_child(sprite)
	
	z_index = -1

func _process(delta):
	if is_equipped:
		offset_position = lerpf(offset_position, OFFSET, 0.05)
		position = (get_global_mouse_position() - player.global_position).limit_length(offset_position)
		sprite.rotation = player.global_position.direction_to(get_global_mouse_position()).angle()
		sprite.flip_v = sprite.rotation < -PI / 2 or sprite.rotation > PI / 2
	else:
		position = Vector2.ZERO

func _input(event):
	if event.is_action_pressed("attack") and can_attack and is_equipped and player.can_move:
		attack()

func attack():
	can_attack = false
	timer.start(recharge_speed)

func _on_timer_timeout():
	can_attack = true
