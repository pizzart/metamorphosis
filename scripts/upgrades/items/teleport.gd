class_name TeleportUpgrade
extends Upgrade

const INACTIVE_TIMEOUT = 0.5

var can_activate: bool = true
var active: bool
var time: float

var timer = Timer.new()
var sprite = AnimatedSprite2D.new()

func _init():
	super._init()
	weight = 1
	timer.timeout.connect(_on_timeout)
	timer.one_shot = true
	timer.wait_time = INACTIVE_TIMEOUT
	add_child(timer)

func _ready():
	sprite.sprite_frames = preload("res://resources/frames/watch.tres")
	sprite.animation = "closed"
	sprite.position = Vector2(0, -5)
	sprite.z_index = -1
	player.add_child.call_deferred(sprite)

func _input(event):
	if event.is_action_pressed("special") and can_activate and player.can_move:
		player.global_position = player.get_global_mouse_position()
		can_activate = false
		
		timer.start()
		var tilemap = player.get_parent().tilemap
		var id = tilemap.get_cell_source_id(0, tilemap.local_to_map(player.global_position))
		if id <= 0 or id == 2:
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
			
			player.global_position = get_tree().get_first_node_in_group("exit").global_position
			player.can_move = true
			player.z_index = old_z
			player.cam.top_level = false
			player.cam.position = Vector2.ZERO
			player.shadow.show()
			
			player.hit(1, Vector2.ZERO)

func _on_timeout():
	can_activate = true
