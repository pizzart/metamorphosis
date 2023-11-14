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
@onready var melee: Melee = $Melee
@onready var shadow = $Shadow

func _ready():
	weight = gun.weight + melee.weight
	buffer_health = weight
	health = max_health - weight
	RenderingServer.global_shader_parameter_set("vignette_opacity", 0.035)
	
	remove_child(shadow)
	get_parent().get_node("TileMap").add_child(shadow)
	
	add_coin()
	add_coin()
	add_coin()
	add_coin()

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
	
	shadow.global_position = global_position + Vector2(0, 4)
	
#	if direction:
#		$PointLight2D.position = direction * 16
#		$PointLight2D.rotation = direction.angle() - PI / 2
	
func _process(delta):
	UI.get_node("Control/M/V/WeightBar").value = lerp(UI.get_node("Control/M/V/WeightBar").value, float(weight), delta * 10)
	UI.get_node("Control/M/V/WeightBar").max_value = max_health
	UI.get_node("Control/M/V/HealthBar").value = lerp(UI.get_node("Control/M/V/HealthBar").value, float(health), delta * 10)
	UI.get_node("Control/M/V/HealthBar").max_value = max_health
	UI.get_node("Control/M/V/HealthBar/Buffer").value = buffer_health
	UI.get_node("Control/M/V/HealthBar/Buffer").max_value = max_health
	UI.get_node("Control/M/V/AmmoBar").value = ammo
	UI.get_node("Control/M/V/AmmoBar").max_value = max_ammo
	$UIBox.global_position = lerp($UIBox.global_position, to_global(Vector2(12, -54)), delta * 10)
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
	
	var health_prev = health
	
	health -= damage
	if health <= 0:
		get_tree().reload_current_scene()
	
	invincible = true
	$InvTimer.start()
	
	Global.freeze_frame()
	
	if health < max_health / 3 and health_prev >= max_health / 3:
		var tween = create_tween()
		tween.tween_method(Global.set_shader_param.bind("vignette_opacity"), 0.035, 0.5, 1.0)
#	else:
#		RenderingServer.global_shader_parameter_set("vignette_opacity", 0.035)

func replace_weapon(new_weapon: Weapon):
	var new_weight = new_weapon.weight
	
	var old_weight
	if new_weapon is Gun:
		old_weight = gun.weight
	else:
		old_weight = melee.weight
		
	if new_weight > old_weight:
		var free = max_health - health
		var added = new_weight - old_weight
		if free < added + buffer_health:
			if health - added > 0:
				health -= added
				buffer_health += added
			else:
				return new_weapon
	elif new_weight < old_weight:
		var released = old_weight - new_weight
		var new_buffer = max(buffer_health - released, 0)
		health += buffer_health - new_buffer
		buffer_health = new_buffer
	
	weight = weight - old_weight + new_weight
	
	var old_weapon
	if new_weapon is Gun:
		old_weapon = gun
	else:
		old_weapon = melee
	
	remove_child(old_weapon)
	new_weapon.is_equipped = old_weapon.is_equipped
	if new_weapon is Gun:
		gun = new_weapon
	else:
		melee = new_weapon
	add_child(new_weapon)
	
	return old_weapon

func add_coin():
	if coins != 0:
		var texture = $UIBox/Grid/T.duplicate(8)
		$UIBox/Grid.add_child(texture)
	else:
		$UIBox/Grid/T.show()
	coins += 1

func spend_coins(amount: int):
	coins = max(coins - amount, 0)
	for i in range($UIBox/Grid.get_child_count() - 1, coins - 1, -1):
		var c = $UIBox/Grid.get_child(i)
		if not c.get_meta("unavailable", false):
			if c.name != "T":
				c.queue_free()

func add_ammo(amount: float):
	ammo = clampf(ammo + amount, 0, max_ammo)

func is_less_gun_weight(gun_weight: int):
	return max_health - melee.weight - gun_weight > 0

func is_less_melee_weight(melee_weight: int):
	return max_health - gun.weight - melee_weight > 0

func show_coins(amount: int):
	$UIBox.show()
	for c in $UIBox/Grid.get_children():
		c.hide()
	for i in range(amount):
		if i >= $UIBox/Grid.get_child_count():
			var texture = $UIBox/Grid/T.duplicate(8)
			texture.modulate = Color.PALE_VIOLET_RED
			texture.set_meta("unavailable", true)
			$UIBox/Grid.add_child(texture)
		elif i < amount:
			if not (amount == 1 and coins == 0):
				$UIBox/Grid.get_child(i).modulate = Color(2, 2, 2)
			else:
				$UIBox/Grid.get_child(i).modulate = Color.PALE_VIOLET_RED
		
	for c in $UIBox/Grid.get_children():
		if is_instance_valid(c):
			c.show()
			await get_tree().create_timer(0.05).timeout
#		$UIBox/Grid.get_child(i).hide()

func hide_coins():
	for c in $UIBox/Grid.get_children():
		if c.get_meta("unavailable", false):
			c.queue_free()
	await get_tree().create_timer(0.1).timeout
	for c in $UIBox/Grid.get_children():
		c.modulate = Color.WHITE
		c.hide()
		await get_tree().create_timer(0.05).timeout
	$UIBox.hide()

#func add_weight(added: int):
#	weight += added
#	health = min(health, max_health - weight - added)

func _on_inv_timer_timeout():
	invincible = false
