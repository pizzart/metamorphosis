extends Node2D

const BOSS = preload("res://scenes/bosses/boss_1.tscn")
const WINDOW = preload("res://scenes/window.tscn")

var generator: Generator

@onready var player: Player = $Player
@onready var tilemap: TileMap = $TileMap

func _ready():
	generator = Generator.new(player, tilemap)
	add_child(generator)
	generator.generate_map(Generator.MAP_SIZE)
	var exit_placement = generator.place_exit(Generator.GenerationType.Intermission)
	generator.place_player(exit_placement)
#	$Window.world_2d = get_window().world_2d

func init_boss_1():
	var player_window = WINDOW.instantiate()
	player_window.camera = player.cam
	player_window.world_2d = get_window().world_2d
	remove_child(player)
	player_window.add_child(player)
	add_child(player_window)
	var enemy_window = WINDOW.instantiate()
	var boss = BOSS.instantiate()
	enemy_window.camera = boss.get_node("Camera")
	enemy_window.world_2d = get_window().world_2d
	enemy_window.add_child(boss)
	add_child(enemy_window)
	get_window().set_canvas_cull_mask_bit(2, false)
	get_window().mode = Window.MODE_FULLSCREEN
