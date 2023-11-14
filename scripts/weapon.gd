class_name Weapon
extends Node2D

const OFFSET = 15
var recharge_speed: float
var weight: int
var knockback: float
var texture: Texture2D
var weapon_name: String = "weapon"

var offset_position: float = OFFSET
var offset_rotation: float = 0
var can_attack: bool = true
var is_equipped: bool = false
var direction: Vector2

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
#	Global.weapon_pool.append(weapon_name)

func _process(delta):
	if is_equipped:
		offset_position = lerpf(offset_position, OFFSET, 0.05)
		var input_dir = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		if input_dir:
			direction = input_dir
			position = direction * offset_position
		else:
			direction = player.global_position.direction_to(get_global_mouse_position())
			position = (get_global_mouse_position() - player.global_position).limit_length(offset_position)
		sprite.position = position.rotated(offset_rotation) - position
		sprite.rotation = direction.angle() + offset_rotation
		sprite.flip_v = sprite.rotation < -PI / 2 or sprite.rotation > PI / 2
	else:
		position = Vector2.ZERO

func attack():
	can_attack = false
	timer.start(recharge_speed)

func can_attack_fr():
	return can_attack and is_equipped and player.can_move

func _on_timer_timeout():
	can_attack = true
