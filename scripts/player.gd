class_name Player
extends CharacterBody2D

const INIT_AMMO = 100
const INIT_SPEED = 120
const INIT_HEALTH = 10
const HAT_Y = -4

var speed = INIT_SPEED
var speed_multiplier: float = 1
var offset_velocity: Vector2
var can_move: bool = true
var invincible: bool = false
var max_health: int = INIT_HEALTH
var health: int = max_health
var weight: int = 0
var max_ammo: float = INIT_AMMO
var ammo: float = max_ammo
var coins: int = 0
var rng = RandomNumberGenerator.new()

@onready var cam: Camera2D = $Camera
@onready var gun: Gun = $Gun
@onready var melee: Weapon = $Melee

func _physics_process(delta):
	if not can_move:
		return
	
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = lerp(velocity, direction * speed * speed_multiplier + offset_velocity, 0.3)
	offset_velocity = lerp(offset_velocity, Vector2.ZERO, 0.3)
	
	move_and_slide()
	
	$PointLight2D.texture_scale = rng.randf_range(0.96, 1.04)
	
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
	weight = gun.weight + ceili(ammo / 10)
	UI.get_node("Control/M/V/WeightBar").value = weight
	UI.get_node("Control/M/V/WeightBar").max_value = max_health
	UI.get_node("Control/M/V/HealthBar").value = health
	UI.get_node("Control/M/V/HealthBar").max_value = max_health
	UI.get_node("Control/M/V/AmmoBar").value = ammo
	UI.get_node("Control/M/V/AmmoBar").max_value = max_ammo
	UI.get_node("Control/M/V/Coins").text = str(coins)
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

func _on_inv_timer_timeout():
	invincible = false
