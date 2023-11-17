class_name World
extends Node2D

const BOSS1 = preload("res://scenes/bosses/boss_1.tscn")
const BOSS3 = preload("res://scenes/bosses/boss_3.tscn")
const WINDOW = preload("res://scenes/window.tscn")

var generator: Generator

@onready var player: Player = $Player
@onready var tilemap: TileMap = $TileMap
@onready var mus = {
	"boss3": $MusicBoss3,
	"abyss_calm": $MusicAbyssCalm,
	"abyss_intense": $MusicAbyssIntense,
}

func _ready():
	generator = Generator.new(player, tilemap)
	if Global.current_area == Generator.Area.City:
		generator.current_area = Generator.Area.City
	add_child(generator)
	if Global.current_area == Generator.Area.City:
#		generator.generate_map_full(Generator.ISLAND_SIZE)
		generator.generate_town()
	else:
#		generator.generate_town()
		generator.generate_map_full(Generator.ISLAND_SIZE)
#	generator.generate_boss()
#	$Window.world_2d = get_window().world_2d

func _process(delta):
	if generator.current_area == Generator.Area.Sky:
		$SkyBG/ParallaxLayer.motion_offset.x -= delta * 10
		$SkyBG/ParallaxLayer3.motion_offset.x -= delta * 7
		$SkyBG/ParallaxLayer4.motion_offset.x -= delta * 13
		$SkyBG/ParallaxLayer5.motion_offset.x -= delta * 3
		$SkyBG/ParallaxLayer7.motion_offset.x -= delta * 5

func init_boss_1():
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

func init_boss3():
	var boss = BOSS3.instantiate()
	call_deferred("add_child", boss)
	play_music("boss3")

func play_music(key: String):
	mus[key].play()

func transition_music(key1: String, key2: String):
	var tween = create_tween().set_parallel()
	tween.tween_property(mus[key1], "volume_db", -80, 5.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(mus[key2], "volume_db", 0, 5.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	mus[key2].volume_db = -80
	mus[key2].play()
	mus[key2].seek(mus[key1].get_playback_position())
