class_name Player
extends CharacterBody2D

signal dead
signal weapon_changed(weapon: Weapon)

const PARTICLES = preload("res://scenes/particles/hit_particles.tscn")

const INIT_AMMO = 100
const INIT_SPEED = 130
const INIT_HEALTH = 12
const MAX_PACKS = 3
const HAT_Y = -4
const COST_BOX_POS = Vector2(12, -54)
const STEP_TIME = 0.4

enum Emotion {
	None,
	Question,
	Warning,
	Waiting,
	Correct,
	Energy,
	Blood,
}

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
var coins_visible: bool = false
var health_packs: int = 0
var step_timer: float

var rng = RandomNumberGenerator.new()

@onready var gun: Gun = Pistol.new()
@onready var melee: Melee = Sword.new()
@onready var cam: Camera2D = $Camera
@onready var shadow = $Shadow
@onready var light = $Light
@onready var coin_box = $CoinBox
@onready var disk_box = $DiskBox
@onready var hat = $V/Sprite/Hat
@onready var emotion_spr = $V/Sprite/Emotion
@onready var sprite = $V/Sprite
@onready var hurt_sfx = $HurtSFX
@onready var death_sfx = $DeathSFX
@onready var change_sfx = $ChangeSFX
@onready var step_sfx = $StepSFX

func _ready():
	add_child(gun)
	add_child(melee)
	
	if Global.equipped_item != Global.Item.None:
		add_child(Global.ITEMS[Global.equipped_item][2].new())
	
	weight = get_weight()
	buffer_health = weight
	health = max_health - weight
	
	if Global.equipped_hat != Global.Hat.None:
		hat.show()
		hat.texture = Global.HATS[Global.equipped_hat][1]
	
	if not OS.has_feature("editor"):
		for i in range(5):
			add_coin()
	
	UI.set_health_packs(health_packs)
	
	add_upgrade(TeleportUpgrade.new())

func _physics_process(_delta):
	var direction: Vector2
	if can_move:
		direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = lerp(velocity, direction * speed * speed_multiplier + offset_velocity, 0.3)
	offset_velocity = lerp(offset_velocity, Vector2.ZERO, 0.2)
	
	move_and_slide()
	
	$Light.texture_scale = rng.randf_range(0.95, 1.04)
	
	if not can_move:
		sprite.speed_scale = 0
		return
	
	sprite.speed_scale = velocity.length() / speed
	
	var i = int(8.0 * (velocity.rotated(PI / 8.0).angle() + PI) / TAU)
	if i == 0 or i == 4:
		sprite.animation = "side"
	if i == 1 or i == 3:
		sprite.animation = "diagonal_back"
	if i == 2:
		sprite.animation = "back"
	if i == 6:
		sprite.animation = "front"
	if i == 5 or i == 7:
		sprite.animation = "diagonal_front"
	
	if velocity.normalized().x < 0:
		sprite.flip_h = true
	elif velocity.normalized().x > 0:
		sprite.flip_h = false
	
#	shadow.global_position = global_position + Vector2(0, 4)
	
#	if direction:
#		$PointLight2D.position = direction * 16
#		$PointLight2D.rotation = direction.angle() - PI / 2
	
func _process(delta):
	UI.get_node("Control/M/Bars/Weight/Bar").value = lerp(UI.get_node("Control/M/Bars/Weight/Bar").value, float(weight), delta * 10)
	UI.get_node("Control/M/Bars/Weight/Bar").max_value = max_health
	UI.get_node("Control/M/Bars/Health/Bar").value = lerp(UI.get_node("Control/M/Bars/Health/Bar").value, float(health), delta * 10)
	UI.get_node("Control/M/Bars/Health/Bar").max_value = max_health
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").value = buffer_health
	UI.get_node("Control/M/Bars/Health/Bar/Buffer").max_value = max_health
	UI.get_node("Control/M/Bars/Ammo/Bar").value = ammo
	UI.get_node("Control/M/Bars/Ammo/Bar").max_value = max_ammo
	coin_box.global_position = lerp(coin_box.global_position, to_global(COST_BOX_POS), delta * 10)
#	UI.get_node("Control/M/V/Coins").text = str(coins)
#	if weight > health:
#		speed_multiplier = 0.5
#	else:
#		speed_multiplier = 1
#	ammo = clampf(ammo + delta * 15, 0, max_ammo)
	emotion_spr.visible = sprite.animation == "front"

func _input(event):
	if event.is_action_pressed("change_gun") and can_move:
		if gun != null and melee != null:
			gun.is_equipped = not gun.is_equipped
			melee.is_equipped = not melee.is_equipped
			change_sfx.play()
	if event.is_action_pressed("heal"):
		if health_packs > 0 and can_move:
			heal(5)
			health_packs -= 1
			UI.set_health_packs(health_packs)
			UI.hide_pack_help()

func knockback(value: Vector2):
	offset_velocity += value

func hit(damage: int, force: Vector2):
	if invincible:
		return
	
	knockback(force * 10)
	
	var health_prev = health
	
	health -= damage
	if health <= 0:
		var disks = floori(coins / 3)
		if disks == 0:
			disk_box.get_node("Grid/T").hide()
		for i in range(disks - 1):
			disk_box.add_child(disk_box.get_node("Grid/T").duplicate(8))
		disk_box.global_position = to_global(COST_BOX_POS) + Vector2(0, coin_box.size.y + 8)
		disk_box.show()
		show_coins(coins)
		
		Global.coins += disks
		
		death_sfx.play()
		can_move = false
		invincible = true
		set_collision_layer_value(1, false)
		
		await get_tree().create_timer(3).timeout
		dead.emit()
	
	hurt_sfx.play()
	
	invincible = true
	$InvTimer.start()
	
	var particles = PARTICLES.instantiate()
	particles.global_position = global_position
	particles.rotation = force.angle()
	particles.emitting = true
	get_parent().add_child(particles)
	
	cam.add_trauma(float(damage) / 4)
	Global.freeze_frame()
	
	if health < max_health / 3:
		if health_prev >= max_health / 3:
			change_emotion(Player.Emotion.Energy)
			var tween = create_tween()
			tween.tween_method(Global.set_shader_param.bind("vignette_opacity"), Global.VIGNETTE_OPACITY, 0.5, 1.0)
		UI.flash_health()
		if health_packs > 0:
			UI.show_pack_help()
	else:
		UI.hide_pack_help()
#	else:
#		RenderingServer.global_shader_parameter_set("vignette_opacity", 0.035)
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color.WHITE

func replace_weapon(new_weapon: Weapon):
	var new_weight = new_weapon.weight
	
	var old_weight: int = 0
	if new_weapon is Gun:
		if gun != null:
			old_weight = gun.weight
	elif melee != null:
		old_weight = melee.weight
	
	if new_weight > old_weight:
		var free = max_health - health
		var added = new_weight - old_weight
		if free < added + buffer_health:
			if health - added > 0:
				health -= added
			else:
				return new_weapon
		buffer_health += added
	elif new_weight < old_weight:
		var released = old_weight - new_weight
		var new_buffer = max(buffer_health - released, 0)
		health += buffer_health - new_buffer
		buffer_health = new_buffer
	
	weight = weight - old_weight + new_weight
	
	var old_weapon
	if new_weapon is Gun:
		if gun != null:
			old_weapon = gun
	elif melee != null:
		old_weapon = melee
	
	if old_weapon != null:
		remove_child(old_weapon)
		new_weapon.is_equipped = old_weapon.is_equipped
	else:
		new_weapon.is_equipped = gun == null and melee == null
	
	if new_weapon is Gun:
		gun = new_weapon
	else:
		melee = new_weapon
	add_child(new_weapon)
	
	weapon_changed.emit(new_weapon)
	change_sfx.play()
	
	if old_weapon != null:
		Global.condition = false
		UI.set_timer_bad()
	
	return old_weapon

func add_coin():
	if coins != 0:
		var texture = coin_box.get_node("Grid/T").duplicate(8)
		coin_box.get_node("Grid").add_child(texture)
	else:
		coin_box.get_node("Grid/T").show()
	coins += 1

func spend_coins(amount: int):
	coins = max(coins - amount, 0)
	for i in range(coin_box.get_node("Grid").get_child_count() - 1, coins - 1, -1):
		var c = coin_box.get_node("Grid").get_child(i)
		if not c.get_meta("unavailable", false):
			if c.name != "T":
				c.queue_free()

func add_ammo(amount: float):
	ammo = clampf(ammo + amount, 0, max_ammo)
	change_emotion(Emotion.None)
	if ammo == max_ammo:
		UI.flash_ammo()

func heal(amount: int):
	health = mini(health + amount, max_health - buffer_health)
	if health >= max_health / 3:
		change_emotion(Emotion.None)
		var tween = create_tween()
		tween.tween_method(Global.set_shader_param.bind("vignette_opacity"), 0.5, Global.VIGNETTE_OPACITY, 1.0)

func add_health_pack():
	health_packs = mini(health_packs + 1, MAX_PACKS)
	UI.set_health_packs(health_packs)

func is_less_gun_weight(gun_weight: int):
	if melee != null:
		return max_health - melee.weight - gun_weight > 0
	else:
		return max_health - gun_weight > 0

func is_less_melee_weight(melee_weight: int):
	if gun != null:
		return max_health - gun.weight - melee_weight > 0
	else:
		return max_health - melee_weight > 0

func show_coins(amount: int):
	coins_visible = true
	
	coin_box.show()
	coin_box.scale = Vector2.ONE
	
	var tween = create_tween()
	tween.tween_interval(0.15)
	tween.tween_callback(coin_box.hide)
	tween.tween_interval(0.05)
	tween.tween_callback(coin_box.show)
	
	for c in coin_box.get_node("Grid").get_children():
		c.hide()
	for i in range(amount):
		if i >= coin_box.get_node("Grid").get_child_count():
			var texture = coin_box.get_node("Grid/T").duplicate(8)
			texture.modulate = Color.PALE_VIOLET_RED
			texture.set_meta("unavailable", true)
			coin_box.get_node("Grid").add_child(texture)
		elif i < amount:
			if not (amount == 1 and coins == 0):
				coin_box.get_node("Grid").get_child(i).modulate = Color(2, 2, 2)
			else:
				coin_box.get_node("Grid").get_child(i).modulate = Color.PALE_VIOLET_RED
		
	for c in coin_box.get_node("Grid").get_children():
		if is_instance_valid(c) and coins_visible:
			c.show()
			await get_tree().create_timer(0.05).timeout
#		coin_box.get_node("Grid").get_child(i).hide()

func hide_coins():
	coins_visible = false
	var disappear_time = 0.05
	var tween = create_tween()
	tween.tween_property(coin_box, "scale", Vector2(1, 0), disappear_time * coin_box.get_node("Grid").get_child_count() + 0.1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	for c in coin_box.get_node("Grid").get_children():
		if c.get_meta("unavailable", false):
			c.queue_free()
	await get_tree().create_timer(0.1).timeout
	for c in coin_box.get_node("Grid").get_children():
		if coins_visible:
			continue
		c.modulate = Color.WHITE
		c.hide()
		await get_tree().create_timer(disappear_time).timeout
	if not coins_visible:
		coin_box.hide()
		coin_box.scale = Vector2.ONE

func shake_coins():
	for i in range(10):
		coin_box.global_position = to_global(COST_BOX_POS + Vector2(rng.randf_range(-3, 3), rng.randf_range(-3, 3)))
		await get_tree().physics_frame

#func add_weight(added: int):
#	weight += added
#	health = min(health, max_health - weight - added)

func add_upgrade(upgrade: Upgrade):
	add_child(upgrade)
	weight = get_weight()

func get_weight():
	var upgrade_weight = 0
	for u in get_tree().get_nodes_in_group("upgrade"):
		upgrade_weight += u.weight
	return gun.weight + melee.weight + upgrade_weight

func change_emotion(emotion: Emotion):
	emotion_spr.texture = load("res://sprites/character/emotions/emotion_%s.png" % emotion)

func _on_inv_timer_timeout():
	invincible = false

func _on_sprite_frame_changed():
	hat.position.y = HAT_Y + sprite.frame % 2
	emotion_spr.position.y = sprite.frame % 2
	if sprite.frame % 2:
		step_sfx.play()
