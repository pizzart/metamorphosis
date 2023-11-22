class_name Generator
extends Node

signal generated

enum GenerationType {
	Action,
	Intermission,
	Boss,
	Town,
	Finale,
}

enum Area {
	Sky,
	City,
	Abyss,
}

const AREA_TEXTURES = {
	Area.Sky: [preload("res://sprites/tilesets/tiles_1.png"), preload("res://sprites/tilesets/bottom_tile_1.png")],
	Area.City: [preload("res://sprites/tilesets/tiles_2.png"), preload("res://sprites/tilesets/bottom_tile_2.png")],
	Area.Abyss: [preload("res://sprites/tilesets/tiles_3.png"), preload("res://sprites/tilesets/bottom_tile_3.png")],
}

const AREA_NAMES = {
	Area.Sky: "sky",
	Area.City: "city",
	Area.Abyss: "abyss",
}

const AREA_SIZES = {
	Area.Sky: 9,
	Area.City: 20,
	Area.Abyss: 25,
}

const ISLAND_SIZE = 9
const ISLAND_CITY_SIZE = 20
const ISLAND_SPREAD = 15
const INTERMISSION_SIZE = 5
const TOWN_SIZE = 15
const MAP_COUNT = 2
const MIN_TELEPORTER_DISTANCE = 50
const TERRAIN_ID = 1
const BOTTOM_ID = 2

const GLITCH_MAT = preload("res://misc/glitch_mat.tres")

const ENEMY = preload("res://scenes/enemy.tscn")
const NPC = preload("res://scenes/npc.tscn")
const EXIT = preload("res://scenes/exit.tscn")
const WINDOW = preload("res://scenes/window.tscn")
const BOSS = preload("res://scenes/bosses/boss_1.tscn")
const VENDING = preload("res://scenes/vending_machine.tscn")
const TREE = preload("res://scenes/tree.tscn")

var rng = RandomNumberGenerator.new()
var current_map: int = 2
var last_player_spawn: Vector2

var player: Player
var tilemap: TileMap
@onready var world: World = get_parent()

func _init(_player, _tilemap):
	player = _player
	tilemap = _tilemap

func _ready():
	update_surroundings()
#	world.play_music("abyss_intense")

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
				world.add_child.call_deferred(teleporter)
	if Global.current_area == Area.City:
		place_walls(0.98)
	var enemy_count = 0
	for i in range(island_count):
		enemy_count += rng.randi_range(3 + pow(Global.current_area, 2), 5 + pow(Global.current_area, 2) + rng.randi_range(0, current_map + Global.current_area))
	place_enemies(enemy_count)

func generate_map_full(size):
	cleanup()
	generate_map(size)
	var exit_placement = place_exit(GenerationType.Intermission)
	place_player(exit_placement)
	generated.emit()

func generate_intermission():
	cleanup()
	place_islands(1, INTERMISSION_SIZE)
	place_pickups()
	var gen_type = GenerationType.Action
	if current_map == MAP_COUNT:
		gen_type = GenerationType.Boss
	var exit_placement = place_exit(gen_type)
	place_player(exit_placement)
	generated.emit()

func generate_town():
	cleanup()
	place_islands(1, TOWN_SIZE)
	var exit_pos = place_exit(GenerationType.Action)
	var player_pos = place_player(exit_pos)
	var all_positions: Array[Vector2i] = [exit_pos, player_pos]
	var prop_positions = place_props()
	all_positions.append_array(prop_positions)
	var vending_pos = place_vending(all_positions)
	all_positions.append(vending_pos)
	place_npcs(all_positions)
	generated.emit()

func generate_boss1():
	cleanup()
	tilemap.set_pattern(0, Vector2i.ZERO, tilemap.tile_set.get_pattern(0))
	var exit_placement = place_exit(GenerationType.Town)
	place_player(exit_placement)
	generated.emit()
	world.init_boss1()

func generate_boss3():
	cleanup()
	tilemap.set_pattern(0, Vector2i.ZERO, tilemap.tile_set.get_pattern(1))
	var exit_placement = place_exit(GenerationType.Finale)
	place_player(exit_placement)
	generated.emit()
	world.init_boss3()

func place_player(exit_placement: Vector2):
	var placement = Vector2i.ZERO
	for cell in tilemap.get_used_cells_by_id(0, TERRAIN_ID):
		if Vector2(cell).distance_to(exit_placement) > Vector2(placement).distance_to(exit_placement):
			placement = cell
	player.global_position = tilemap.map_to_local(placement)
	last_player_spawn = player.global_position
	return placement

func place_islands(count: int, size: int):
	var init_positions = []
	var cells: Array[Vector2i] = []
	for i in range(count):
		var island_start = Vector2i.ZERO
		if i > 0:
			island_start = Vector2i(rng.randi_range(-ISLAND_SPREAD, ISLAND_SPREAD), rng.randi_range(-ISLAND_SPREAD, ISLAND_SPREAD))
		cells.append_array(place_tile(cells, size, island_start, 0.8))
		init_positions.append(tilemap.map_to_local(island_start))
	tilemap.set_cells_terrain_connect(0, cells, 0, 0)
	var borders = place_borders(cells)
	for cell in borders.keys():
		if borders[cell]:
			tilemap.set_cell(0, cell, BOTTOM_ID, Vector2i.ZERO)
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
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var placements = []
	for i in range(count):
		if not cells.is_empty():
			var j = rng.randi() % cells.size()
			while tilemap.get_cell_source_id(1, cells[j]) != -1:
				j = rng.randi() % cells.size()
			placements.append(cells.pop_at(j))
	for placement in placements:
		var enemy = choose(Global.enemy_pool[Global.current_area]).new()
		enemy.global_position = tilemap.map_to_local(placement)
		if Global.current_area == Area.Abyss:
			enemy.modulate = Color.BLACK
		world.add_child.call_deferred(enemy)

func place_walls(chance: float):
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var new_cells: Array[Vector2i] = []
	for cell in cells:
		if rng.randf() > chance:
#			tilemap.set_cell(1, cell, 2, Vector2i.ZERO)
			var width = rng.randi_range(3, 5)
			var height = rng.randi_range(2, 5)
			for x in range(width):
				for y in range(height):
					var layer = 1
					if y != 0:
						layer = 2
					
					var tile_pos = Vector2i.ZERO
					if y == 0:
						tile_pos.y = 2
					elif y != height - 1:
						tile_pos.y = 1
					if x == width - 1:
						tile_pos.x = 2
					elif x != 0:
						tile_pos.x = 1
					
					tilemap.set_cell(layer, cell + Vector2i(x, -y), 3, tile_pos)
				for xx in range(-1, 2):
					for yy in range(-1, 2):
						var dir = Vector2i(xx, yy)
						if not cell + dir in cells:
							cells.append(cell + dir)
							new_cells.append(cell + dir)
	tilemap.set_cells_terrain_connect(0, cells, 0, 0)
	for cell in new_cells:
		for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			if not cell + dir in tilemap.get_surrounding_cells(cell):
				var tile = 0
				if dir == Vector2i.DOWN:
					tile = BOTTOM_ID
				tilemap.set_cell(0, cell + dir, tile, Vector2i.ZERO)

func place_exit(next_gen_type: GenerationType) -> Vector2i:
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var placement = cells[0]
	var center = tilemap.get_used_rect().get_center()
	for cell in cells:
		if Vector2(cell).distance_to(center) > Vector2(placement).distance_to(center):
			placement = cell
	var exit = EXIT.instantiate()
	exit.global_position = tilemap.map_to_local(placement)
	exit.body_entered.connect(_on_exit_entered.bind(next_gen_type))
	world.add_child.call_deferred(exit)
	return placement

func place_pickups():
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var placement = cells.pop_at(rng.randi() % cells.size())
	while not placement + Vector2i.LEFT in cells and not placement + Vector2i.RIGHT in cells and not cells.is_empty():
		placement = cells.pop_at(rng.randi() % cells.size())
	
	var gun_placement = tilemap.map_to_local(placement + Vector2i.LEFT)
	var melee_placement = tilemap.map_to_local(placement + Vector2i.RIGHT)
	
	var gun = Global.weapon_pool["gun"].pick_random().new()
	var melee = Global.weapon_pool["melee"].pick_random().new()
	var gun_pickup = Box.new(gun)
	var melee_pickup = Box.new(melee)
	gun_pickup.global_position = gun_placement
	melee_pickup.global_position = melee_placement
	world.add_child.call_deferred(gun_pickup)
	world.add_child.call_deferred(melee_pickup)

func place_npcs(taken_positions: Array[Vector2i]):
	var dialogues: Array = Global.DIALOGUES.get(Global.current_area, []).duplicate()
	
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var positions = []
	for i in range(3):
		if not cells.is_empty():
			var j = rng.randi() % cells.size()
			for pos in taken_positions:
				while tilemap.get_cell_source_id(1, cells[j]) != -1 or (cells[j] - pos).length() < 3:
					cells.remove_at(j)
					j = rng.randi() % cells.size()
			positions.append(cells.pop_at(j))
	for pos in positions:
		if dialogues.is_empty():
			continue
		var npc = NPC.instantiate()
		npc.global_position = tilemap.map_to_local(pos)
		npc.lines = dialogues.pop_at(rng.randi() % dialogues.size())
		world.add_child.call_deferred(npc)

func place_vending(taken_positions: Array[Vector2i]):
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var j = rng.randi() % cells.size()
	for pos in taken_positions:
		while (cells[j] - pos).length() < 3:
			cells.remove_at(j)
			j = rng.randi() % cells.size()
	var vending = VENDING.instantiate()
	vending.global_position = tilemap.map_to_local(cells[j])
	world.add_child.call_deferred(vending)
	return cells[j]

func place_props():
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var sum = Vector2i.ZERO
	for cell in cells:
		sum += cell
	var position = sum / cells.size()
	
	var tree = TREE.instantiate()
	tree.global_position = tilemap.map_to_local(position)
	world.add_child.call_deferred(tree)
	return [position]

func cleanup():
	tilemap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("teleporter", "queue_free")
	get_tree().call_group("exit", "queue_free")
	get_tree().call_group("projectile", "queue_free")
	get_tree().call_group("cleanup", "queue_free")

func update_surroundings():
	tilemap.tile_set.get_source(TERRAIN_ID).texture = AREA_TEXTURES[Global.current_area][0]
	tilemap.tile_set.get_source(BOTTOM_ID).texture = AREA_TEXTURES[Global.current_area][1]
	match Global.current_area:
		Area.City:
			world.get_node("SkyBG").hide()
			world.get_node("SkyModulate").hide()
			world.get_node("CityBG").show()
			world.get_node("CityModulate").show()
		Area.Abyss:
			world.get_node("SkyBG").hide()
			world.get_node("SkyModulate").hide()
			world.get_node("CityBG").hide()
			world.get_node("CityModulate").hide()
			world.get_node("AbyssBG").show()
			world.get_node("AbyssModulate").show()
			
			world.get_node("AbyssBG/ParallaxLayer/Sprite2D").material = GLITCH_MAT
			tilemap.material = GLITCH_MAT

func choose(dict: Dictionary):
	var sum: float = 0
	for val in dict.values():
		sum += val

	var normalized_weights = []

	for val in dict.values():
		normalized_weights.append(val / sum)

	var rnd = rng.randf()

	var i = 0
	var summer: float = 0

	for val in normalized_weights:
		summer += val
		if summer >= rnd:
			return dict.keys()[i]
		i += 1

func _on_exit_entered(_body: Node2D, next_gen_type: GenerationType):
	match next_gen_type:
		GenerationType.Action:
			if current_map == MAP_COUNT:
				Global.current_area += 1
				current_map = 0
				update_surroundings()
				cleanup()
				world.show_selection()
			else:
				current_map += 1
				world.transition_music("%s_calm" % AREA_NAMES[Global.current_area], "%s_intense" % AREA_NAMES[Global.current_area])
				generate_map_full(AREA_SIZES[Global.current_area])
		GenerationType.Intermission:
			generate_intermission()
			world.transition_music("%s_intense" % AREA_NAMES[Global.current_area], "%s_calm" % AREA_NAMES[Global.current_area])
		GenerationType.Boss:
			match Global.current_area:
				Area.Sky:
					generate_boss1()
				Area.City:
					world.init_boss2()
				Area.Abyss:
					generate_boss3()
		GenerationType.Town:
			Global.purchasable_hats.append(Global.current_area + 1)
			Global.purchasable_items.append(Global.current_area + 1)
			generate_town()
		GenerationType.Finale:
			cleanup()
			world.init_finale()
