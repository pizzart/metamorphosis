class_name WingsUpgrade
extends Upgrade

const TIMEOUT = 2.5
const INACTIVE_TIMEOUT = 5

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
	sprite.sprite_frames = preload("res://resources/frames/wings.tres")
	sprite.animation = "closed"
	sprite.position = Vector2(0, -5)
	sprite.z_index = -1
	player.add_child.call_deferred(sprite)

func _process(delta):
	if active:
		time += delta
		if time >= TIMEOUT:
			deactivate()

func _input(event):
	if event.is_action_pressed("special"):
		if can_activate and player.can_move:
			active = true
			sprite.animation = "open"
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
	
	var tilemap = player.get_parent().tilemap
	if tilemap.get_cell_source_id(0, tilemap.local_to_map(player.global_position)) <= 0:
		player.can_move = false
		var old_z = player.z_index
		player.z_index = -10
		player.cam.top_level = true
		player.cam.global_position = player.global_position
		player.shadow.hide()
		
		var tween = create_tween()
		tween.tween_interval(0.1)
		tween.tween_property(player, "global_position", player.global_position + Vector2(0, 200), 0.6).set_trans(Tween.TRANS_CIRC)
		await tween.finished
		
		player.hit(1, Vector2.ZERO)
		player.global_position = player.get_parent().generator.last_player_spawn
		player.can_move = true
		player.z_index = old_z
		player.cam.top_level = false
		player.cam.position = Vector2.ZERO
		player.shadow.show()
	
	player.set_collision_layer_value(1, true)
	player.set_collision_mask_value(4, true)

func _on_timeout():
	can_activate = true
