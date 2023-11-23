class_name World
extends Node2D

const BOSS1 = preload("res://scenes/bosses/boss_1.tscn")
const BOSS3 = preload("res://scenes/bosses/boss_3.tscn")
const WINDOW = preload("res://scenes/window.tscn")
const PLAYER = preload("res://scenes/player.tscn")

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
}

func _ready():
	UI.show()
	RenderingServer.global_shader_parameter_set("vignette_opacity", Global.VIGNETTE_OPACITY)
	
	if Global.player_state != null:
		player = Global.player_state
	else:
		player = PLAYER.instantiate()
	add_child(player)
	
	generator = Generator.new(player, tilemap)
	add_child(generator)
	if Global.after_boss:
#		generator.generate_map_full(Generator.ISLAND_SIZE)
		play_music("%s_calm" % Generator.AREA_NAMES[Global.current_area])
		generator.current_map = 2
		generator.generate_town()
	else:
		play_music("%s_intense" % Generator.AREA_NAMES[Global.current_area])
		generator.generate_map_full(Generator.ISLAND_SIZE)
#		init_finale()

func _process(delta):
	Global.timer += delta
	if Global.current_area == Generator.Area.Sky:
		$SkyBG/ParallaxLayer.motion_offset.x -= delta * 10
		$SkyBG/ParallaxLayer3.motion_offset.x -= delta * 7
		$SkyBG/ParallaxLayer4.motion_offset.x -= delta * 13
		$SkyBG/ParallaxLayer5.motion_offset.x -= delta * 3
		$SkyBG/ParallaxLayer7.motion_offset.x -= delta * 5
	if $SelectionScreen:
		$SelectionScreen.offset = -(get_viewport().get_mouse_position() - get_viewport_rect().size / 2) / 8

func init_boss1():
	pass
#	get_window().set_canvas_cull_mask_bit(2, false)
	
#	var tilemap_window = WINDOW.instantiate()
#	tilemap_window.world_2d = get_window().world_2d
#	tilemap_window.set_canvas_cull_mask_bit(2, false)
#	tilemap_window.size = Vector2(600, 600)
#	add_child(tilemap_window)
#	remove_child(tilemap)
#	tilemap_window.add_child(tilemap)

#	var enemy_window = WINDOW.instantiate()
#	var boss = BOSS.instantiate()
#	enemy_window.camera = boss.get_node("Camera")
#	enemy_window.world_2d = get_window().world_2d
##	enemy_window.set_canvas_cull_mask_bit(1, false)
#	enemy_window.set_canvas_cull_mask_bit(3, false)
#	add_child(enemy_window)
#	enemy_window.add_child(boss)
	
#	get_window().mode = Window.MODE_FULLSCREEN

func init_boss2():
	Global.player_state = player
	remove_child(player)
	get_tree().change_scene_to_file("res://scenes/3d/world_3d.tscn")

func init_boss3():
	var boss = BOSS3.instantiate()
	add_child.call_deferred(boss)
	fade_music_out(1)
	play_music("boss3")
	fade_music_in("boss3", 2)

func init_finale():
	fade_music_out(10)
	player.global_position = Vector2.ZERO
	add_child.call_deferred(preload("res://scenes/finale.tscn").instantiate())

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
	tween.tween_property(mus[key], "volume_db", 0, time).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)

func show_selection():
	fade_music_out(2)
	player.can_move = false
	var mod1 = Global.modifier_pool.pop_at(Global.rng.randi() % Global.modifier_pool.size())
	var mod2 = Global.modifier_pool.pop_at(Global.rng.randi() % Global.modifier_pool.size())
	$SelectionScreen/Control/Modifier1.icon = load("res://sprites/ui/modifiers/modifier_%s.png" % str(mod1).pad_zeros(2))
	$SelectionScreen/Control/Modifier2.icon = load("res://sprites/ui/modifiers/modifier_%s.png" % str(mod2).pad_zeros(2))
	$SelectionScreen/Control/Modifier1.pressed.connect(_on_mod1_pressed.bind(mod1))
	$SelectionScreen/Control/Modifier2.pressed.connect(_on_mod2_pressed.bind(mod2))
	$SelectionScreen.show()
	UI.hide()

func _on_mod1_pressed(modifier):
	player.add_upgrade(Global.MODIFIERS[modifier].new())
	init_new_area()

func _on_mod2_pressed(modifier):
	player.add_upgrade(Global.MODIFIERS[modifier].new())
	init_new_area()

func init_new_area():
	UI.show()
	player.can_move = true
	$SelectionScreen/Control/Modifier1.pressed.disconnect(_on_mod1_pressed)
	$SelectionScreen/Control/Modifier2.pressed.disconnect(_on_mod2_pressed)
	$SelectionScreen.hide()
	fade_music_in("%s_intense" % Generator.AREA_NAMES[Global.current_area], 2)
	generator.generate_map_full(Generator.AREA_SIZES[Global.current_area])
