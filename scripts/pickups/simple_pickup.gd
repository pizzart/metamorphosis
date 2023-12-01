class_name SimplePickup
extends Pickup

const PARTICLES = preload("res://scenes/particles/pickup_particles.tscn")

var time: float

var audio = AudioStreamPlayer2D.new()
var particles: CPUParticles2D

func _init(shape: Shape2D, texture: Texture2D):
	super._init(shape, texture)
	
	particles = PARTICLES.instantiate()
	var stream = AudioStreamRandomizer.new()
	stream.add_stream(0, preload("res://audio/sfx/collect.wav"))
	audio.stream = stream
	audio.bus = "sfx"
	z_index = 1
	add_child(audio)
	add_child(particles)

func _input(event):
	if event.is_action_pressed("use") and can_interact:
		interact()

func _process(delta):
	time += delta
	sprite.position.y = sin(time) * 5

func interact():
	set_deferred("monitoring", false)
	can_interact = false
	particles.emitting = false
	audio.play()
	var tween = create_tween().set_parallel()
	tween.tween_property(sprite, "scale", Vector2(0, 10), 0.4).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "position", Vector2(0, -150), 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()
