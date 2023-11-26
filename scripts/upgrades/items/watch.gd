class_name WatchUpgrade
extends Upgrade

const SLOW_TIME_SCALE = 0.2
const TIMEOUT = 5 * SLOW_TIME_SCALE
const INACTIVE_TIMEOUT = 7

var can_activate: bool = true
var active: bool
var time: float

var timer = Timer.new()
var sprite = AnimatedSprite2D.new()

func _init():
	super._init()
	weight = 3
	timer.timeout.connect(_on_timeout)
	timer.one_shot = true
	timer.wait_time = INACTIVE_TIMEOUT
	add_child(timer)

func _ready():
	sprite.sprite_frames = preload("res://resources/frames/watch.tres")
	sprite.autoplay = "closed"
	sprite.position = Vector2(0, -5)
	sprite.z_index = 1
	player.add_child.call_deferred(sprite)

func _process(delta):
	if active:
		Engine.time_scale = lerpf(Engine.time_scale, SLOW_TIME_SCALE, delta * 15)
		time += delta
		if time >= TIMEOUT:
			deactivate()

func _input(event):
	if event.is_action_pressed("special"):
		if can_activate and player.can_move:
			active = true
			sprite.animation = "open"
			var tween = create_tween()
			tween.tween_method(Global.set_shader_param.bind("blue_strength"), 0.0, 1.0, 0.5)
			
			player.set_collision_layer_value(1, false)
			player.set_collision_mask_value(4, false)

	if event.is_action_released("special"):
		if active:
			deactivate()

func deactivate():
	time = 0
	can_activate = false
	active = false
	timer.start()
	sprite.animation = "closed"
	
	var tween = create_tween().set_parallel()
	tween.tween_method(Global.set_shader_param.bind("blue_strength"), 1.0, 0.0, 0.5)
	tween.tween_property(Engine, "time_scale", 1.0, 0.5)
	
	player.set_collision_layer_value(1, true)
	player.set_collision_mask_value(4, true)

func _on_timeout():
	can_activate = true
