class_name Generator
extends Node

enum GenerationType {
	Action,
	Intermission,
	Boss,
	Town,
}

enum Area {
	Sky,
	City,
	Abyss,
} 

const AREA_TILES = {
	0: [1, 2],
	1: [3, 4],
	2: [5, 4],
}

const ISLAND_SIZE = 9
const ISLAND_CITY_SIZE = 15
const ISLAND_SPREAD = 15
const INTERMISSION_SIZE = 5
const TOWN_SIZE = 13
const MAP_COUNT = 2
const MIN_TELEPORTER_DISTANCE = 50

const ENEMY = preload("res://scenes/enemy.tscn")
const NPC = preload("res://scenes/npc.tscn")
const EXIT = preload("res://scenes/exit.tscn")
const WINDOW = preload("res://scenes/window.tscn")
const BOSS = preload("res://scenes/bosses/boss_1.tscn")

var rng = RandomNumberGenerator.new()
var pickup_pool = [
	Pistol,
	Rifle,
	Shotgun,
]
var current_map: int = 0
var current_area: Area = Area.Abyss

var player: Player
var tilemap: TileMap
@onready var world: World = get_parent()

func _init(_player, _tilemap):
	player = _player
	tilemap = _tilemap

func generate_map(size):
	var island_count = rng.randi_range(1, 4)
	var positions = place_islands(island_count, size)
	if island_count > 1:
		var new_positions = positions # what the hell
#		for i in range(positions.size()):
#			var to_add = true
#			for j in range(positions.size()):
#				if positions[i].distance_to(positions[j]) < MIN_TELEPORTER_DISTANCE:
#					to_add = false
#					break
#			if to_add:
#			new_positions.append(positions[i])
		if new_positions.size() > 1:
			for i in range(new_positions.size()):
				var j = i + 1
				if j >= new_positions.size():
					j = 0
				var teleporter = Teleporter.new(new_positions[i], new_positions[j])
				world.call_deferred("add_child", teleporter)
#	place_walls(0.97)
	var enemy_count = 0
	for i in range(island_count):
		enemy_count += rng.randi_range(3, 5 + rng.randi_range(0, current_map))
	place_enemies(enemy_count)

func regenerate_map(size):
	cleanup()
	generate_map(size)
	var exit_placement = place_exit(GenerationType.Intermission)
	place_player(exit_placement)

func generate_intermission():
	cleanup()
	place_islands(1, INTERMISSION_SIZE)
	place_pickups()
	var gen_type = GenerationType.Action
	if current_map == MAP_COUNT:
		gen_type = GenerationType.Boss
	var exit_placement = place_exit(gen_type)
	place_player(exit_placement)

func generate_town():
	cleanup()
	place_islands(1, TOWN_SIZE)
	var exit_placement = place_exit(GenerationType.Action)
	place_player(exit_placement)
	place_npcs()

func generate_boss():
	tilemap.clear()
	cleanup()
	tilemap.set_pattern(0, Vector2i.ZERO, tilemap.tile_set.get_pattern(0))
	var exit_placement = place_exit(GenerationType.Town)
	place_player(exit_placement)
	world.init_boss_1()

func place_player(exit_placement: Vector2):
	var placement = Vector2i.ZERO
	for cell in tilemap.get_used_cells_by_id(0, AREA_TILES[current_area][0]):
		if Vector2(cell).distance_to(exit_placement) > Vector2(placement).distance_to(exit_placement):
			placement = cell
	player.global_position = tilemap.map_to_local(placement)

func place_islands(count: int, size: int):
	var init_positions = []
	var cells: Array[Vector2i] = []
	for i in range(count):
		var island_start = Vector2i.ZERO
		if i > 0:
			island_start = Vector2i(rng.randi_range(-ISLAND_SPREAD, ISLAND_SPREAD), rng.randi_range(-ISLAND_SPREAD, ISLAND_SPREAD))
		cells.append_array(place_tile(cells, size, island_start, 0.8))
		init_positions.append(tilemap.map_to_local(island_start))
	tilemap.set_cells_terrain_connect(0, cells, current_area, 0)
	var borders = place_borders(cells)
	for cell in borders.keys():
		if borders[cell]:
			tilemap.set_cell(0, cell, AREA_TILES[current_area][1], Vector2i.ZERO)
		else:
			tilemap.set_cell(0, cell, 0, Vector2i.ZERO)
	return init_positions

func place_tile(cells: Array[Vector2i], count: int, placement: Vector2i, chance: float):
	if placement in cells:
		return cells
	
	var gen_chance = 1
	if count <= 0:
		gen_chance = rng.randf_range(count / 10, 1)
	
	if gen_chance > chance:
		cells.append(placement)
		for i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]:
			place_tile(cells, count - 1, placement + i, chance)
	return cells
#	else:
#		tilemap.set_cell(0, placement, 1, Vector2i.ZERO)

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
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, AREA_TILES[current_area][0])
	var placements = []
	for i in range(count):
		if not cells.is_empty():
			var j = rng.randi() % cells.size()
			while tilemap.get_cell_source_id(1, cells[j]) != -1:
				j = rng.randi() % cells.size()
			placements.append(cells.pop_at(j))
	for placement in placements:
		var enemy = ENEMY.instantiate()
		enemy.global_position = tilemap.map_to_local(placement)
		world.call_deferred("add_child", enemy)

func place_walls(chance: float):
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, AREA_TILES[current_area][0])
	for cell in cells:
		if rng.randf() > chance:
			tilemap.set_cell(1, cell, 2, Vector2i.ZERO)
#			for i in range(3):
#				tilemap.set_cell(2, cell - Vector2i(0, i), 3, Vector2i.ZERO)

func place_exit(next_gen_type: GenerationType) -> Vector2i:
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, AREA_TILES[current_area][0])
	var placement = cells[0]
	var center = tilemap.get_used_rect().get_center()
	for cell in cells:
		if Vector2(cell).distance_to(center) > Vector2(placement).distance_to(center):
			placement = cell
	var exit = EXIT.instantiate()
	exit.global_position = tilemap.map_to_local(placement)
	exit.body_entered.connect(_on_exit_entered.bind(next_gen_type))
	world.call_deferred("add_child", exit)
	return placement

func place_pickups():
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, AREA_TILES[current_area][0])
	for i in range(3):
		var placement = cells.pop_at(rng.randi() % cells.size())
		placement = tilemap.map_to_local(placement)
		var gun = pickup_pool.pick_random().new()
		var pickup = GunPickup.new(gun.weapon_name, gun)
		pickup.global_position = placement
		world.call_deferred("add_child", pickup)

func place_npcs():
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, AREA_TILES[current_area][0])
	var placements = []
	for i in range(3):
		if not cells.is_empty():
			var j = rng.randi() % cells.size()
			while tilemap.get_cell_source_id(1, cells[j]) != -1:
				j = rng.randi() % cells.size()
			placements.append(cells.pop_at(j))
	for placement in placements:
		var npc = NPC.instantiate()
		npc.global_position = tilemap.map_to_local(placement)
		world.call_deferred("add_child", npc)

func cleanup():
	tilemap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("pickup", "queue_free")
	get_tree().call_group("teleporter", "queue_free")
	get_tree().call_group("exit", "queue_free")
	get_tree().call_group("projectile", "queue_free")

func _on_exit_entered(_body: Node2D, next_gen_type: GenerationType):
	match next_gen_type:
		GenerationType.Action:
			if current_map == MAP_COUNT:
				current_area += 1
			var island_size = ISLAND_SIZE
			if current_area == Area.City:
				island_size = ISLAND_CITY_SIZE
			regenerate_map(island_size)
			current_map += 1
		GenerationType.Intermission:
			generate_intermission()
		GenerationType.Boss:
			match current_area:
				Area.Sky:
					generate_boss()
				Area.City:
					get_tree().change_scene_to_file("res://scenes/3d/world_3d.tscn")
				Area.Abyss:
					pass
		GenerationType.Town:
			generate_town()
