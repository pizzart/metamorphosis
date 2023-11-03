extends Node2D

const MAP_SIZE = 15
const ENEMY = preload("res://scenes/enemy.tscn")
const EXIT = preload("res://scenes/exit.tscn")
var exit
var RNG = RandomNumberGenerator.new()
@onready var player = $Player

func _ready():
	RNG.randomize()
	generate_map()

func generate_map():
	var island_count = RNG.randi_range(1, 4)
	for i in range(island_count):
		place_tile(MAP_SIZE, Vector2i(RNG.randi_range(-10, 10), RNG.randi_range(-10, 10)), 0.9)
	place_enemies(5)
	place_exit()

func regenerate_map():
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	exit.body_entered.disconnect(_on_exit_entered)
	exit.queue_free()
	generate_map()
	player.global_position = $TileMap.map_to_local($TileMap.get_used_cells_by_id(0, 0)[0])

func place_tile(count, placement, chance):
	if $TileMap.get_cell_source_id(0, placement) == 0:
		return
	
	var gen_chance = 1
	if count <= 0:
		gen_chance = RNG.randf_range(count / 10, 1)
	if gen_chance > chance:
		$TileMap.set_cell(0, placement, 0, Vector2i.ZERO)
		for i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			place_tile(count - 1, placement + i, chance)
	else:
		$TileMap.set_cell(0, placement, 1, Vector2i.ZERO)

func place_enemies(count):
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0, Vector2i.ZERO)
	var placements = []
	for i in range(count):
		var j = RNG.randi() % cells.size()
		while $TileMap.get_cell_source_id(1, cells[j]) != -1:
			j = RNG.randi() % cells.size()
		placements.append(cells.pop_at(j))
	for placement in placements:
		var enemy = ENEMY.instantiate()
		enemy.global_position = $TileMap.map_to_local(placement)
		call_deferred("add_child", enemy)

func place_exit():
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0, Vector2i.ZERO)
	var placement = $TileMap.map_to_local(cells[-1])
	exit = EXIT.instantiate()
	exit.global_position = placement
	exit.body_entered.connect(_on_exit_entered)
	call_deferred("add_child", exit)

func _input(event):
	if event.is_action_pressed("reload_map"):
		regenerate_map()

func _on_exit_entered(body):
	regenerate_map()
