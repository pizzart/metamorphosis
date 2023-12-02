class_name World
extends Node2D

const WINDOW = preload("res://scenes/window.tscn")
const PLAYER = preload("res://scenes/player.tscn")
const CHECK = preload("res://scenes/particles/check_particle.tscn")

var player: Player
var generator: Generator

@onready var tilemap: TileMap = $TileMap
@onready var mus = {
	"boss3": $MusicBoss3,
	"abyss_calm": $MusicAbyssCalm,
	"abyss_intense": $MusicAbyssIntense,
	"city_calm": $MusicCityCalm,
	"city_intense": $MusicCityIntense,
	"sky_calm": $MusicSkyCalm,
	"sky_intense": $MusicSkyIntense,
	"finale": $MusicFinale,
}

func _ready():
	RenderingServer.global_shader_parameter_set("vignette_opacity", Global.VIGNETTE_OPACITY)
	PauseMenu.can_show = true
	Global.set_game_cursor()
	UI.show()
	if Global.condition:
		UI.set_timer_good()
	UI.transition_in(0)
	
	if Global.player_state != null:
		player = Global.player_state
	else:
		player = PLAYER.instantiate()
	player.can_move = false
	add_child(player)
	
	player.dead.connect(_on_player_dead)
	
	generator = Generator.new(player, tilemap)
	add_child(generator)
	if Global.after_boss:
#		generator.generate_map_full(Generator.ISLAND_SIZE)
#		play_music("%s_calm" % Generator.AREA_NAMES[Global.current_area])
		generator.current_map = 2
		generator.generate_town()
	else:
		play_music("%s_intense" % Generator.AREA_NAMES[Global.current_area])
#		generator.thread.start(generator.generate_map_full.bind(Generator.AREA_SIZES[Global.current_area]))
		generator.generate_map_full(Generator.AREA_SIZES[Global.current_area])
#		generator.generate_boss3()

func _process(delta):
	if not $SelectionWindow.visible:
		Global.timer += delta
		UI.set_time(Global.timer)
	if Global.current_area == Generator.Area.Sky:
		$SkyBG/ParallaxLayer.motion_offset.x -= delta * 10
		$SkyBG/ParallaxLayer3.motion_offset.x -= delta * 7
		$SkyBG/ParallaxLayer4.motion_offset.x -= delta * 13
		$SkyBG/ParallaxLayer5.motion_offset.x -= delta * 3
		$SkyBG/ParallaxLayer7.motion_offset.x -= delta * 5
#	if $SelectionScreen:
#		$SelectionScreen.offset = -(get_viewport().get_mouse_position() - get_viewport_rect().size / 2) / 8

func _physics_process(_delta):
	var closest = [INF, null]
	for i in get_tree().get_nodes_in_group("interactable"):
		var dist = player.global_position.distance_squared_to(i.global_position)
		i.can_interact = false
		if i.inside and dist < closest[0]:
			closest = [dist, i]
	if closest[1] != null:
		closest[1].can_interact = true

func init_boss2():
	Global.player_state = player
	remove_child(player)
	get_tree().change_scene_to_file("res://scenes/3d/world_3d.tscn")

func init_boss3():
	fade_music_out(1)
	play_music("boss3")
	fade_music_in("boss3", 3)

func init_finale():
#	player.global_position = Vector2.ZERO
	add_child.call_deferred(preload("res://scenes/finale.tscn").instantiate())
	fade_music_in("finale", 1)
	await get_tree().create_timer(1).timeout
	play_music("finale")

func play_music(key: String):
	mus[key].play()

func transition_music(from: String, to: String):
	var tween = create_tween().set_parallel()
	tween.tween_property(mus[from], "volume_db", -80, 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(mus[to], "volume_db", 0, 3.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	mus[to].volume_db = -80
	mus[to].play()
	mus[to].seek(mus[from].get_playback_position())

func fade_music_out(time: float):
	for music in mus.values():
		var tween = create_tween()
		tween.tween_property(music, "volume_db", -80, time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func fade_music_in(key: String, time: float):
	mus[key].volume_db = -80
	mus[key].play()
	var tween = create_tween()
	tween.tween_property(mus[key], "volume_db", 0, time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func show_selection():
	fade_music_out(2)
	PauseMenu.can_show = false
	player.can_move = false
	Global.set_menu_cursor()
	var mod1 = Global.modifier_pool.pop_at(Global.rng.randi() % Global.modifier_pool.size())
	var mod2 = Global.modifier_pool.pop_at(Global.rng.randi() % Global.modifier_pool.size())
	$SelectionWindow/SelectionUI/Modifier1.icon = load("res://sprites/ui/modifiers/modifier_%s.png" % str(mod1).pad_zeros(2))
	$SelectionWindow/SelectionUI/Modifier2.icon = load("res://sprites/ui/modifiers/modifier_%s.png" % str(mod2).pad_zeros(2))
	$SelectionWindow/SelectionUI/Modifier1.pressed.connect(_on_mod_pressed.bind(mod1))
	$SelectionWindow/SelectionUI/Modifier2.pressed.connect(_on_mod_pressed.bind(mod2))
	$SelectionWindow/SelectionUI/Modifier1.mouse_entered.connect(_on_mod_hovered.bind(mod1))
	$SelectionWindow/SelectionUI/Modifier2.mouse_entered.connect(_on_mod_hovered.bind(mod2))
	$SelectionWindow/SelectionUI/Modifier1.mouse_exited.connect(_on_mod_unhovered)
	$SelectionWindow/SelectionUI/Modifier2.mouse_exited.connect(_on_mod_unhovered)
	$SelectionWindow.show()
#	UI.hide()

func _on_mod_pressed(modifier):
	player.add_upgrade(Global.MODIFIERS[modifier].new())
	PauseMenu.can_show = true
	Global.set_game_cursor()
	init_new_area()

func init_new_area():
#	UI.show()
	player.can_move = true
	$SelectionWindow/SelectionUI/Modifier1.pressed.disconnect(_on_mod_pressed)
	$SelectionWindow/SelectionUI/Modifier2.pressed.disconnect(_on_mod_pressed)
	$SelectionWindow/SelectionUI/Weight.hide()
	$SelectionWindow.hide()
	fade_music_in("%s_intense" % Generator.AREA_NAMES[Global.current_area], 2)
	generator.generate_map_full(Generator.AREA_SIZES[Global.current_area])

func _on_mod_hovered(modifier):
	$SelectionWindow/SelectionUI/Weight.show()
	$SelectionWindow/SelectionUI/Weight.text = "+%s weight" % Global.MODIFIERS[modifier].WEIGHT

func _on_mod_unhovered():
	$SelectionWindow/SelectionUI/Weight.hide()

func _on_boss3_dead():
	get_tree().get_first_node_in_group("exit").enemies_gone = true
	fade_music_out(10)

func _on_player_dead():
	get_tree().change_scene_to_file("res://scenes/pre_ui.tscn")

func _on_exit_arrived():
	generator.boss = true
	generator.place_enemies(10, tilemap.local_to_map(get_tree().get_first_node_in_group("exit").global_position))
	await get_tree().create_timer(5).timeout
	for i in range(50):
		generator.place_enemies(Global.rng.randi_range(2, 3), tilemap.local_to_map(get_tree().get_first_node_in_group("exit").global_position))
		await get_tree().create_timer(2).timeout
	
	var exit = get_tree().get_first_node_in_group("exit")
	exit.enemies_gone = true
	await get_tree().create_timer(0.5).timeout
	exit.play_fin_sound()
	var check = CHECK.instantiate()
	check.restart()
	check.global_position = player.global_position + Vector2(4, -4)
	add_child(check)
	fade_music_out(10)
#	transition_music("%s_intense" % Generator.AREA_NAMES[Global.current_area], "%s_calm" % Generator.AREA_NAMES[Global.current_area])
	player.change_emotion(Player.Emotion.Correct)
#	var boss = BOSS3.instantiate()
#	boss.dead.connect(_on_boss3_dead)
#	add_child.call_deferred(boss)
