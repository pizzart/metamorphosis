class_name World
extends Node2D

const BOSS = preload("res://scenes/bosses/boss_1.tscn")
const WINDOW = preload("res://scenes/window.tscn")

var generator: Generator

@onready var player: Player = $Player
@onready var tilemap: TileMap = $TileMap
@onready var mus = {
	"boss3": $MusicBoss3
}

func _ready():
	generator = Generator.new(player, tilemap)
	if Global.after_3d:
		generator.current_area = Generator.Area.Abyss
	add_child(generator)
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

func play_music(key: String):
	mus[key].play()
