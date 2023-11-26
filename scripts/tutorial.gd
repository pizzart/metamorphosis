extends Node2D

const BOSS = preload("res://scenes/bosses/boss_0.tscn")

var box: Box
var pickup = WeaponPickup.new(Sword.NAME, Sword.new())

@onready var player = $Player
@onready var tilemap = $TileMap

func _ready():
	player.gun.queue_free()
	player.melee.queue_free()
	player.ammo = 0
	player.weight = 0
	player.dead.connect(_on_player_dead)
	
	box = Box.new(Pistol.new())
	box.global_position = $BoxPos.global_position
	box.broken.connect(_on_box_broken)
	add_child(box)
	pickup.global_position = $SwordPos.global_position
	pickup.picked_up.connect(_on_sword_picked_up)
	add_child(pickup)
	
	var teleport1 = Teleporter.new($TelePos1.global_position, $TelePos2.global_position)
	var teleport2 = Teleporter.new($TelePos2.global_position, $TelePos5.global_position)
	var teleport3 = Teleporter.new($TelePos3.global_position, $TelePos4.global_position)
	var teleport4 = Teleporter.new($TelePos5.global_position, $TelePos1.global_position)
	add_child(teleport1)
	add_child(teleport2)
	add_child(teleport3)
	add_child(teleport4)

func _process(delta):
	$BG/ParallaxLayer.motion_offset.x -= delta * 100
	$BG/ParallaxLayer2.motion_offset.x -= delta * 50

func _physics_process(delta):
	var closest = [INF, null]
	for i in get_tree().get_nodes_in_group("interactable"):
		var dist = player.global_position.distance_squared_to(i.global_position)
		i.can_interact = false
		if i.inside and dist < closest[0]:
			closest = [dist, i]
	if closest[1] != null:
		closest[1].can_interact = true

func _on_box_broken(pickup: WeaponPickup):
	pickup.picked_up.connect(_on_gun_picked_up)

func _on_sword_picked_up():
	var teleport2 = Teleporter.new($TelePos4.global_position, $TelePos3.global_position)
	add_child(teleport2)
	
	$HelpWindow/Help/C/Key/Label.hide()
	$HelpWindow/Help/C/Key/MouseLeft.show()
	$HelpWindow.position = get_window().position + Vector2i(get_window().size.x, get_window().size.y / 2)
	$HelpWindow.show()
	$Timer.start()

func _on_gun_picked_up():
	$Wall.queue_free()
	$HelpWindow/Help/C/Key/Label.text = "space"
	$HelpWindow/Help/C/Key/MouseLeft.hide()
	$HelpWindow/Help/C/Key/Label.show()
	$HelpWindow.position = get_window().position + Vector2i(get_window().size.x, get_window().size.y / 2)
	$HelpWindow.show()
	
	$Timer.stop()
	await get_tree().create_timer(8).timeout
	
	$HelpWindow/Help/C.hide()
	$HelpWindow/Help/AmmoHelp.show()
	
	$Timer.start()

func _on_player_dead():
	get_tree().reload_current_scene()

func _on_boss_area_body_entered(body):
	var boss = BOSS.instantiate()
	boss.global_position = $BossPos.global_position
	boss.dead.connect(_on_boss_dead)
	add_child.call_deferred(boss)
	$Wall2/CollisionShape2D.set_deferred("disabled", false)
	$BossArea.set_deferred("monitoring", false)

func _on_boss_dead():
	var teleport = Teleporter.new($TelePos6.global_position, $TelePos4.global_position)
	add_child.call_deferred(teleport)
	$Exit.enemies_gone = true

func _on_exit_moved():
	get_tree().change_scene_to_file("res://scenes/pre_ui.tscn")

func _on_timer_timeout():
	$HelpWindow.hide()
	$HelpWindow/Help/C.show()
	$HelpWindow/Help/AmmoHelp.hide()