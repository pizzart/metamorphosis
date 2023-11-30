class_name DashUpgrade
extends Upgrade

const INACTIVE_TIMEOUT = 0.6

var can_activate: bool = true
var active: bool

var timer = Timer.new()

func _init():
	super._init()
	weight = 1
	timer.timeout.connect(_on_timeout)
	timer.one_shot = true
	timer.wait_time = INACTIVE_TIMEOUT
	add_child(timer)

func _ready():
	var area = Area2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(48, 48)
	var col_shape = CollisionShape2D.new()
	col_shape.shape = shape
	area.add_child(col_shape)
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(2, true)
	area.body_entered.connect(_on_body_entered)
	player.add_child(area)

func _input(event):
	if event.is_action_pressed("special") and can_activate and player.can_move:
		can_activate = false
		active = true
		
		player.override_velocity = player.global_position.direction_to(player.get_global_mouse_position()) * 600
		await get_tree().create_timer(0.13).timeout
		player.override_velocity *= 0.3
		var tween = create_tween()
		tween.tween_property(player, "override_velocity", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished
		active = false
		timer.start()

func _on_timeout():
	can_activate = true

func _on_body_entered(body):
	if active and body is Foe:
		body.hit(1, player.override_velocity.normalized() * 200)
		
		active = false
		timer.start()
		player.override_velocity = -player.override_velocity.normalized() * 400
		var tween = create_tween()
		tween.tween_property(player, "override_velocity", Vector2.ZERO, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
