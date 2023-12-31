class_name Gun
extends Weapon

var ammo_cost: int
var spread: float
var bullet_speed: float
var bullet_acceleration: float
var bullet_damage: int = 1

var error_audio: AudioStreamPlayer2D = AudioStreamPlayer2D.new()

func _init(_ammo_cost: int, _reload_speed: float, _knockback: float, _spread: float, _weight: int, \
			_bullet_speed: float, _bullet_acceleration: float, _texture: Texture2D, _gun_name: String):
	ammo_cost = _ammo_cost
	spread = _spread
	bullet_speed = _bullet_speed
	bullet_acceleration = _bullet_acceleration
	super._init(_reload_speed, _weight, _knockback, _texture, _gun_name)
	is_equipped = true
	
	var stream = AudioStreamRandomizer.new()
	stream.add_stream(0, preload("res://audio/sfx/shoot.wav"))
	audio.stream = stream
	error_audio.stream = preload("res://audio/sfx/error.wav")
	error_audio.bus = "sfx"
	add_child(error_audio)

func _input(event):
	if event.is_action_pressed("attack") and can_attack_fr():
		if player.ammo >= ammo_cost:
			attack()
		else:
			player.change_emotion(Player.Emotion.Blood)
			error_audio.play()

func attack():
	super.attack()
	scale = Vector2(0.75, 1.25)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	player.cam.add_trauma(0.2)
	player.ammo -= ammo_cost

func send_bullet():
	var bullet = Bullet.new(direction.rotated(rng.randfn(0, spread)) * bullet_speed, bullet_acceleration, true)
	bullet.damage = bullet_damage
	bullet.global_position = global_position
	player.get_parent().add_child(bullet)
	
	offset_position = OFFSET / 4
	player.knockback(-direction * knockback)
