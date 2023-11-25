class_name Box
extends Area2D

signal broken(pickup: WeaponPickup)

const PARTICLES = preload("res://scenes/particles/box_particles.tscn")

var sprite = Sprite2D.new()
var audio = AudioStreamPlayer2D.new()
var can_interact: bool
var item: Weapon

func _init(_item):
	set_collision_layer_value(1, false)
	set_collision_mask_value(3, true)
	
	area_entered.connect(_on_area_entered)
	
	add_to_group("cleanup")
	
	item = _item
	
	var rect = RectangleShape2D.new()
	rect.size = Vector2(24, 36)
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = rect
	
	if item is Gun:
		sprite.texture = preload("res://sprites/props/box_gun.png")
	else:
		sprite.texture = preload("res://sprites/props/box_melee.png")
	
	var stream = AudioStreamRandomizer.new()
	stream.add_stream(0, preload("res://audio/sfx/box_hit.wav"))
	audio.stream = stream
	
	add_child(sprite)
	add_child(audio)
	add_child(collision_shape)
	
	set_collision_layer_value(6, true)
	set_collision_mask_value(6, true)

func _process(delta):
	if monitoring:
		if not get_overlapping_areas().is_empty():
			for area in get_overlapping_areas():
				position += (global_position - area.global_position).limit_length(10) * delta * 5

func break_box():
	var pickup = WeaponPickup.new(item.weapon_name, item)
	pickup.global_position = global_position
	get_parent().add_child.call_deferred(pickup)
	var particles = PARTICLES.instantiate()
	particles.global_position = global_position
	particles.restart()
	get_parent().add_child.call_deferred(particles)
	set_deferred("monitoring", false)
	audio.play()
	hide()
	broken.emit(pickup)
	await audio.finished
	queue_free()

func _on_area_entered(area):
	if area is Projectile:
		break_box()
