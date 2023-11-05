class_name Player
extends CharacterBody2D

var speed = 120
var max_health: int = 10
var health: int = max_health
var weight: int = 0
var max_ammo: float = 100
var ammo: float = max_ammo
var speed_multiplier: float = 1
var offset_velocity: Vector2

@onready var cam = $Camera
@onready var gun = $Gun

func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = lerp(velocity, direction * speed * speed_multiplier + offset_velocity, 0.3)
	offset_velocity = lerp(offset_velocity, Vector2.ZERO, 0.4)
	if direction.x > 0:
		$Sprite.animation = "side"
		$Sprite.flip_h = false
	if direction.x < 0:
		$Sprite.animation = "side"
		$Sprite.flip_h = true
	if direction.y > 0:
		$Sprite.animation = "front"
	if direction.y < 0:
		$Sprite.animation = "back"
	
	move_and_slide()
	
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
#	if weight > health:
#		speed_multiplier = 0.5
#	else:
#		speed_multiplier = 1
	ammo = clampf(ammo + delta * 10, 0, max_ammo)

#func _input(event):
#	if event.is_action_pressed("change_gun"):
#		gun.queue_free()
#		gun = Rifle.new()
#		add_child(gun)
#		add_child(SpeedUpgrade.new())

func knockback(value: Vector2):
	offset_velocity += value

func hit(damage: int):
	health -= damage

func replace_gun(new_gun: Gun):
	gun.queue_free()
	gun = new_gun
	add_child(gun)
