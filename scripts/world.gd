extends Node2D

const MAP_SIZE = 10
const INTERMISSION_SIZE = 5
const CITY_SIZE = 12
const ENEMY = preload("res://scenes/enemy.tscn")
const EXIT = preload("res://scenes/exit.tscn")
const PICKUP = preload("res://scenes/pickup.tscn")
const WINDOW = preload("res://scenes/window.tscn")
const BOSS = preload("res://scenes/bosses/boss_1.tscn")
var RNG = RandomNumberGenerator.new()
var pickup_pool = [
	Pistol,
	Rifle,
	Shotgun,
]
@onready var player: Player = $Player

func _ready():
	RNG.randomize()
	generate_map(MAP_SIZE)
	var exit_placement = place_exit(false)
	place_player(exit_placement)
#	$Window.world_2d = get_window().world_2d
#	get_window().set_canvas_cull_mask_bit(2, false)

func generate_map(size):
	var island_count = RNG.randi_range(1, 4)
	var positions = place_islands(island_count, MAP_SIZE)
	if island_count > 1:
		for i in range(positions.size()):
			print(positions[i], $TileMap.get_cell_tile_data(0, $TileMap.local_to_map(positions[i])))
			var j = i + 1
			if j >= positions.size():
				j = 0
#			if positions[i].distance_to(positions[j]) < 200:
#				positions.remove_at(i)
#				continue
			
			var teleporter = Teleporter.new(positions[j])
			teleporter.global_position = positions[i]
			call_deferred("add_child", teleporter)
#	place_walls(0.97)
	place_enemies(5)

func regenerate_map(size):
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("exit", "queue_free")
	generate_map(size)
	var exit_placement = place_exit(false)
	place_player(exit_placement)

func generate_intermission():
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("exit", "queue_free")
	get_tree().call_group("teleporter", "queue_free")
	place_islands(1, INTERMISSION_SIZE)
	place_pickups()
	var exit_placement = place_exit(true)
	place_player(exit_placement)

func generate_city():
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("exit", "queue_free")
	get_tree().call_group("teleporter", "queue_free")
	place_islands(1, CITY_SIZE)
	var exit_placement = place_exit(true)
	place_player(exit_placement)

func place_player(exit_placement: Vector2):
	var placement = Vector2i.ZERO
	for cell in $TileMap.get_used_cells_by_id(0, 0):
		if Vector2(cell).distance_to(exit_placement) > Vector2(placement).distance_to(exit_placement):
			placement = cell
	player.global_position = $TileMap.map_to_local(placement)

func place_islands(count: int, size: int):
	var init_positions = []
	var cells: Array[Vector2i] = []
	for i in range(count):
		var island_start = Vector2i.ZERO
		if i > 0:
			island_start = Vector2i(RNG.randi_range(-15, 15), RNG.randi_range(-15, 15))
		cells.append_array(place_tile(cells, size, island_start, 0.9))
		init_positions.append($TileMap.map_to_local(island_start))
	$TileMap.set_cells_terrain_connect(0, cells, 0, 0)
	var borders = place_borders(cells)
	for cell in borders.keys():
		if borders[cell]:
			$TileMap.set_cell(0, cell, 2, Vector2i.ZERO)
		else:
			$TileMap.set_cell(0, cell, 1, Vector2i.ZERO)
	return init_positions

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
	var border_cells = {}
	for cell in used_cells:
		for i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			if cell + i in used_cells:
				continue
			
			if cell + i in border_cells.keys():
				if not border_cells[cell + i] and i == Vector2i.DOWN:
					border_cells[cell + i] = true
			else:
				border_cells[cell + i] = i == Vector2i.DOWN
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

func place_exit(is_intermission: bool) -> Vector2i:
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0)
	var placement = cells[0]
	var center = $TileMap.get_used_rect().get_center()
	for cell in cells:
		if Vector2(cell).distance_to(center) > Vector2(placement).distance_to(center):
			placement = cell
	var exit = EXIT.instantiate()
	exit.global_position = $TileMap.map_to_local(placement)
	exit.body_entered.connect(_on_exit_entered.bind(is_intermission))
	call_deferred("add_child", exit)
	return placement

func place_pickups():
	var cells: Array[Vector2i] = $TileMap.get_used_cells_by_id(0, 0)
	for i in range(3):
		var placement = cells.pop_at(RNG.randi() % cells.size())
		placement = $TileMap.map_to_local(placement)
		var gun = pickup_pool.pick_random().new()
		var pickup = GunPickup.new(gun.weapon_name, gun)
		pickup.global_position = placement
		call_deferred("add_child", pickup)

func init_boss_1():
	var player_window = WINDOW.instantiate()
	player_window.camera = player.get_node("Camera")
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

func _input(event):
	if event.is_action_pressed("reload_map"):
		print("\n\n")
		get_tree().reload_current_scene()

func _on_exit_entered(_body: Node2D, is_intermission: bool):
	if is_intermission:
		regenerate_map(MAP_SIZE)
	else:
		generate_intermission()
