extends Node2D

const MAP_SIZE = 15
const INTERMISSION_SIZE = 5
const ENEMY = preload("res://scenes/enemy.tscn")
const EXIT = preload("res://scenes/exit.tscn")
const PICKUP = preload("res://scenes/pickup.tscn")
var RNG = RandomNumberGenerator.new()
var pickup_pool = [
	Pistol,
	Rifle,
]
@onready var player: Player = $Player

func _ready():
	RNG.randomize()
	generate_map(MAP_SIZE)
	place_player()

func generate_map(size):
	var island_count = RNG.randi_range(1, 4)
	place_islands(island_count, MAP_SIZE)
#	place_walls(0.97)
	place_enemies(5)
	place_exit(false)

func regenerate_map(size):
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("exit", "queue_free")
	generate_map(size)
	place_player()

func generate_intermission():
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("exit", "queue_free")
	place_islands(1, INTERMISSION_SIZE)
	place_pickups()
	place_exit(true)
	place_player()

func place_player():
	player.global_position = $TileMap.map_to_local($TileMap.get_used_cells_by_id(0, 0).pick_random())

func place_islands(count: int, size: int):
	var cells: Array[Vector2i] = []
	for i in range(count):
		var island_start = Vector2i.ZERO
		if i > 0:
			island_start = Vector2i(RNG.randi_range(-5, 5), RNG.randi_range(-5, 5))
		cells.append_array(place_tile(cells, size, island_start, 0.9))
	$TileMap.set_cells_terrain_connect(0, cells, 0, 0)
	for cell in place_borders(cells):
		$TileMap.set_cell(0, cell, 1, Vector2i.ZERO)

func place_tile(cells: Array[Vector2i], count: int, placement: Vector2i, chance: float):
	if placement in cells:
		return cells
	
	var gen_chance = 1
	if count <= 0:
		gen_chance = RNG.randf_range(count / 10, 1)
	
	if gen_chance > chance:
		cells.append(placement)
		for i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			place_tile(cells, count - 1, placement + i, chance)
	return cells
#	else:
#		$TileMap.set_cell(0, placement, 1, Vector2i.ZERO)

func place_borders(used_cells: Array[Vector2i]):
	var border_cells = []
	for cell in used_cells:
		for i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			if not cell + i in used_cells:
				border_cells.append(cell + i)
	return border_cells

func place_enemies(count: int):
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0)
	var placements = []
	for i in range(count):
		if not cells.is_empty():
			var j = RNG.randi() % cells.size()
			while $TileMap.get_cell_source_id(1, cells[j]) != -1:
				j = RNG.randi() % cells.size()
			placements.append(cells.pop_at(j))
	for placement in placements:
		var enemy = ENEMY.instantiate()
		enemy.global_position = $TileMap.map_to_local(placement)
		call_deferred("add_child", enemy)

func place_walls(chance: float):
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0)
	for cell in cells:
		if RNG.randf() > chance:
			$TileMap.set_cell(1, cell, 2, Vector2i.ZERO)
#			for i in range(3):
#				$TileMap.set_cell(2, cell - Vector2i(0, i), 3, Vector2i.ZERO)

func place_exit(is_intermission: bool):
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0)
	var placement = $TileMap.map_to_local(cells[0])
	for cell in cells:
		var local_cell = $TileMap.map_to_local(cell)
		if local_cell.distance_to(player.global_position) > placement.distance_to(player.global_position):
			placement = local_cell
	var exit = EXIT.instantiate()
	exit.global_position = placement
	exit.body_entered.connect(_on_exit_entered.bind(is_intermission))
	call_deferred("add_child", exit)

func place_pickups():
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0)
	for i in range(3):
		var placement = cells.pop_at(RNG.randi() % cells.size())
		placement = $TileMap.map_to_local(placement)
		var gun = pickup_pool.pick_random().new()
		var pickup = PICKUP.instantiate()
		pickup.init_properties(placement, gun.gun_name, gun)
		call_deferred("add_child", pickup)

func _input(event):
	if event.is_action_pressed("reload_map"):
		regenerate_map(MAP_SIZE)

func _on_exit_entered(_body: Node2D, is_intermission: bool):
	if is_intermission:
		regenerate_map(MAP_SIZE)
	else:
		generate_intermission()
