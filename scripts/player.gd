class_name Player
extends CharacterBody2D

const INIT_AMMO = 100
const INIT_SPEED = 120
const INIT_HEALTH = 15
const HAT_Y = -4

var speed = INIT_SPEED
var speed_multiplier: float = 1
var offset_velocity: Vector2
var can_move: bool = true
var invincible: bool = false
var max_health: int = INIT_HEALTH
var health: int = max_health
var buffer_health: int = 0
var weight: int = 0
var max_ammo: float = INIT_AMMO
var ammo: float = max_ammo
var coins: int = 0
var rng = RandomNumberGenerator.new()

@onready var cam: Camera2D = $Camera
@onready var gun: Gun = $Gun
@onready var melee: Weapon = $Melee

func _ready():
	weight = gun.weight + melee.weight
	buffer_health = weight
	health = max_health - weight

func _physics_process(delta):
	if not can_move:
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = lerp(velocity, direction * speed * speed_multiplier + offset_velocity, 0.3)
	offset_velocity = lerp(offset_velocity, Vector2.ZERO, 0.3)
	
	move_and_slide()
	
	$Light.texture_scale = rng.randf_range(0.95, 1.04)
	
	$Sprite.speed_scale = velocity.length() / speed
	$Sprite.flip_h = direction.x < 0
	if abs(direction.x) > 0 and abs(direction.y) < 0.25:
		$Sprite.animation = "side"
	if direction.y > 0 and abs(direction.x) >= 0.25:
		$Sprite.animation = "diagonal_front"
	if direction.y > 0 and abs(direction.x) < 0.25:
		$Sprite.animation = "front"
	if direction.y < 0 and abs(direction.x) < 0.25:
		$Sprite.animation = "back"
	if direction.y < 0 and abs(direction.x) >= 0.25:
		$Sprite.animation = "diagonal_back"
	
#	if direction:
#		$PointLight2D.position = direction * 16
#		$PointLight2D.rotation = direction.angle() - PI / 2
	
func _process(delta):
	var offset = get_global_mouse_position() - global_position
	cam.offset = offset / 4
	UI.get_node("Control/M/V/WeightBar").value = weight
	UI.get_node("Control/M/V/WeightBar").max_value = max_health
	UI.get_node("Control/M/V/HealthBar").value = health
	UI.get_node("Control/M/V/HealthBar").max_value = max_health
	UI.get_node("Control/M/V/HealthBar/Buffer").max_value = max_health
	UI.get_node("Control/M/V/HealthBar/Buffer").value = buffer_health
	UI.get_node("Control/M/V/AmmoBar").value = ammo
	UI.get_node("Control/M/V/AmmoBar").max_value = max_ammo
#	UI.get_node("Control/M/V/Coins").text = str(coins)
#	if weight > health:
#		speed_multiplier = 0.5
#	else:
#		speed_multiplier = 1
#	ammo = clampf(ammo + delta * 15, 0, max_ammo)
	$Sprite/Hat.position.y = HAT_Y + $Sprite.frame % 2

func _input(event):
	if event.is_action_pressed("change_gun"):
		gun.is_equipped = not gun.is_equipped
		melee.is_equipped = not melee.is_equipped

func knockback(value: Vector2):
	offset_velocity += value

func hit(damage: int):
	if invincible:
		return
	health -= damage
	if health <= 0:
		get_tree().reload_current_scene()
	invincible = true
	$InvTimer.start()

func replace_gun(new_gun: Gun):
	if new_gun.weight > gun.weight:
		var free = max_health - health
		var buffer = free - new_gun.weight
		if buffer < 0:
			buffer_health = abs(buffer)
			health -= buffer_health
	elif new_gun.weight < gun.weight:
		var released = gun.weight - new_gun.weight
		var new_buffer = max(buffer_health - released, 0)
		health += buffer_health - new_buffer
		buffer_health = new_buffer
	weight = new_gun.weight + melee.weight
	var old_gun = gun
	remove_child(old_gun)
	gun = new_gun
	gun.is_equipped = old_gun.is_equipped
	add_child(gun)
	return old_gun

func add_coin():
	coins += 1

func add_ammo(amount: float):
	ammo = clampf(ammo + amount, 0, max_ammo)

func is_less_gun_weight(gun_weight: int):
	return max_health - melee.weight - gun_weight > 0

#func add_weight(added: int):
#	weight += added
#	health = min(health, max_health - weight - added)

func _on_inv_timer_timeout():
	invincible = false
