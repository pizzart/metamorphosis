class_name DashUpgrade
extends Upgrade

const INACTIVE_TIMEOUT = 0.45

var can_activate: bool = true
var active: bool

var timer = Timer.new()
var area = Area2D.new()

func _init():
	super._init()
	weight = 1
	timer.timeout.connect(_on_timeout)
	timer.one_shot = true
	timer.wait_time = INACTIVE_TIMEOUT
	add_child(timer)

func _ready():
	var shape = RectangleShape2D.new()
	shape.size = Vector2(48, 48)
	var col_shape = CollisionShape2D.new()
	col_shape.shape = shape
	area.add_child(col_shape)
	area.set_collision_mask_value(1, false)
	area.set_collision_mask_value(2, true)
	area.set_collision_mask_value(3, true)
	area.monitoring = false
	area.body_entered.connect(_on_node_entered)
	area.area_entered.connect(_on_node_entered)
	player.add_child(area)

func _input(event):
	if event.is_action_pressed("special") and can_activate and player.can_move:
		can_activate = false
		active = true
		player.invincible = true
		area.set_deferred("monitoring", true)
		player.dash_particles.emitting = true
		player.dash_sfx.play()
		
		player.override_velocity = player.global_position.direction_to(player.get_global_mouse_position()) * 650
		await get_tree().create_timer(0.15).timeout
		player.invincible = false
		player.override_velocity *= 0.4
		var tween = create_tween()
		tween.tween_property(player, "override_velocity", Vector2.ZERO, 0.23).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished
		player.dash_particles.emitting = false
		area.set_deferred("monitoring", false)
		active = false
		timer.start()

func _on_timeout():
	can_activate = true

func _on_node_entered(node):
	if active:
		if node is Bullet:
			if node.type == Bullet.BulletType.ENEMY:
				node.set_by_player()
				node.velocity = -node.velocity
				return
			else:
				return
		if node is Foe:
			node.hit(1, player.override_velocity.normalized() * 200)
		
		timer.start()
		player.override_velocity *= 0.4
		var tween = create_tween()
		tween.tween_property(player, "override_velocity", Vector2.ZERO, 0.23).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		await tween.finished
		active = false
		player.invincible = false
		player.dash_particles.emitting = false
		area.set_deferred("monitoring", false)
