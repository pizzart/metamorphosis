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
	Area.Abyss: 15,
}

const ISLAND_SPREAD = 18
const INTERMISSION_SIZE = 5
const TOWN_SIZE = 14
const MAP_COUNT = 2
const MIN_TELEPORTER_DISTANCE = 50
const TERRAIN_ID = 1
const BOTTOM_ID = 2

const GLITCH_MAT = preload("res://misc/glitch_mat.tres")
const CHECK = preload("res://scenes/particles/check_particle.tscn")

const NPC = preload("res://scenes/npc.tscn")
const EXIT = preload("res://scenes/exit.tscn")
const WINDOW = preload("res://scenes/window.tscn")
const VENDING = preload("res://scenes/vending_machine.tscn")
const TREE = preload("res://scenes/props/tree.tscn")
const POLE = preload("res://scenes/props/pole.tscn")
const TURBINE = preload("res://scenes/props/turbine.tscn")
const LAMP = preload("res://scenes/props/lamp.tscn")

var rng = RandomNumberGenerator.new()
var current_map: int = 2
var enemies_left: int
var last_player_spawn: Vector2
var boss: bool

var player: Player
var tilemap: TileMap
@onready var world: World = get_parent()

func _init(_player, _tilemap):
	player = _player
	tilemap = _tilemap

func _ready():
	if not OS.has_feature("editor"):
		current_map = 0

	# stupid fix for betterterrain
	for t in tilemap.tile_set.get_source(TERRAIN_ID).get_tiles_count():
		tilemap.set_cell(0, Vector2i.ZERO, 1, tilemap.tile_set.get_source(TERRAIN_ID).get_tile_id(t), 0)
	tilemap.set_cell(0, Vector2i.ZERO, -1)
	
	update_surroundings()

func generate_map(size):
	var added_count = rng.randi_range(0, current_map + 1)
	var island_count = rng.randi_range(1 + Global.current_area + added_count, 4 + Global.current_area + added_count)
	var islands = place_islands(island_count, size)
	var tp_positions = []
	if island_count > 1:
		if islands[0].size() > 1:
			for i in range(islands[0].size()):
				var j = i + 1
				if j >= islands[0].size():
					j = 0
				var teleporter = Teleporter.new(islands[0][i], islands[0][j])
				world.add_child.call_deferred(teleporter)
				tp_positions.append(tilemap.local_to_map(islands[0][i]))
	return [island_count, islands[1], tp_positions]

func generate_map_full(size):
	cleanup()
	var islands = generate_map(size)
	var cells = islands[1]
	var exit_pos = place_exit(cells, GenerationType.Intermission, true)
	var enemy_count = 0
	for i in range(islands[0]):
		enemy_count += rng.randi_range(3 + Global.current_area, 6 + Global.loop * 2 + Global.current_area + rng.randi_range(0, current_map))
	enemies_left = enemy_count
	var positions: Array[Vector2i] = place_enemies(enemy_count, exit_pos)
	positions.append_array(islands[2])
	positions.append_array(place_poles(cells, [exit_pos]))
	positions.append(exit_pos)
	if Global.current_area == Area.City:
		var wall_cells = place_walls(cells, positions)
		cells.append_array(wall_cells)
	place_borders(cells)
	generated.emit()

func generate_intermission():
	cleanup()
	var islands = place_islands(1, INTERMISSION_SIZE)
	place_borders(islands[1])
	place_pickups(islands[1])
	var gen_type = GenerationType.Action
	if current_map == MAP_COUNT:
		gen_type = GenerationType.Boss
	var exit_pos = place_exit(islands[1], gen_type, false)
	var vending_pos = place_vending(islands[1], [exit_pos])
	generated.emit()

func generate_town():
	cleanup()
	var islands = place_islands(1, TOWN_SIZE)
	place_borders(islands[1])
	var exit_pos = place_exit(islands[1], GenerationType.Action, false)
	var all_positions: Array[Vector2i] = [exit_pos]
	var prop_positions = place_props(islands[1])
	all_positions.append_array(prop_positions)
	var vending_pos = place_vending(islands[1], all_positions)
	all_positions.append(vending_pos)
	place_npcs(islands[1], all_positions)
	generated.emit()

func generate_boss1():
	cleanup()
	tilemap.set_pattern(0, Vector2i.ZERO, tilemap.tile_set.get_pattern(0))
	var exit_pos = place_exit(tilemap.get_used_cells_by_id(0, TERRAIN_ID), GenerationType.Town, true)
	enemies_left = 10
	place_enemies(10, exit_pos)
	generated.emit()
	world.init_boss1()

func generate_boss3():
	cleanup()
	tilemap.set_pattern(0, Vector2i.ZERO, tilemap.tile_set.get_pattern(1))
	var _exit_placement = place_exit(tilemap.get_used_cells_by_id(0, TERRAIN_ID), GenerationType.Finale, true, true)
	generated.emit()
	world.init_boss3()

func place_islands(count: int, size: int) -> Array:
	var init_positions = []
	var cells: Array[Vector2i] = []
	for i in range(count):
		var island_start = Vector2i.ZERO
		if i > 0:
			island_start = Vector2i(rng.randi_range(-ISLAND_SPREAD, ISLAND_SPREAD), rng.randi_range(-ISLAND_SPREAD, ISLAND_SPREAD))
		cells.append_array(place_tile(cells, size, island_start, 0.8))
		init_positions.append(tilemap.map_to_local(island_start))
	
	BetterTerrain.set_cells(tilemap, 0, cells, 0)
	BetterTerrain.update_terrain_cells(tilemap, 0, cells)
	return [init_positions, cells]

func place_borders(cells: Array[Vector2i]):
	var borders = get_borders(cells)
	for cell in borders.keys():
		if borders[cell]:
			tilemap.set_cell(0, cell, BOTTOM_ID, Vector2i.ZERO)
		else:
			tilemap.set_cell(0, cell, 0, Vector2i.ZERO)

func place_tile(cells: Array[Vector2i], count: int, placement: Vector2i, chance: float) -> Array[Vector2i]:
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

func get_borders(used_cells: Array[Vector2i]):
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

func place_enemies(count: int, exit_pos: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = tilemap.get_used_cells_by_id(0, TERRAIN_ID)
	var placements: Array[Vector2i] = []
	for i in range(count):
		if not cells.is_empty():
			var j = rng.randi() % cells.size()
			while tilemap.get_cell_source_id(1, cells[j]) != -1 or (cells[j] - exit_pos).length_squared() < 17:
				j = rng.randi() % cells.size()
			placements.append(cells.pop_at(j))
	for placement in placements:
		var enemy = choose(Global.enemy_pool[Global.current_area]).new()
		enemy.health *= Global.loop + 1
		enemy.global_position = tilemap.map_to_local(placement)
		if Global.current_area == Area.Abyss:
			enemy.modulate = Color.BLACK
		enemy.dead.connect(_on_enemy_dead)
		world.add_child.call_deferred(enemy)
	return placements

func place_walls(cells: Array[Vector2i], taken_positions: Array[Vector2i]) -> Array[Vector2i]:
	var clone = cells.duplicate()
	var taken_clone = taken_positions.duplicate()
	var new_cells: Array[Vector2i] = []
	for i in range(max(cells.size() / 1400, 1)):
		var j = rng.randi() % clone.size()
		for pos in taken_clone:
			while (clone[j] - pos).length_squared() <= 200:
				clone.remove_at(j)
				j = rng.randi() % clone.size()
		var pos = clone[j]
		var pattern = tilemap.tile_set.get_pattern(rng.randi_range(2, 6))
		tilemap.set_pattern(1, clone[j], pattern)
		var placed_cells = []
		for cell in pattern.get_used_cells():
			placed_cells.append(cell + pos)
			taken_clone.append(cell + pos)
			for x in range(-1, 2):
				for y in range(-1, 2):
					if x == 0 and y == 0:
						continue
					var new = cell + pos + Vector2i(x, y)
					if not new in placed_cells:
						placed_cells.append(new)
		BetterTerrain.set_cells(tilemap, 0, placed_cells, 0)
		BetterTerrain.update_terrain_cells(tilemap, 0, placed_cells)
		new_cells.append_array(placed_cells)
	return new_cells

func place_exit(cells: Array[Vector2i], next_gen_type: GenerationType, with_enemies: bool, is_boss: bool = false) -> Vector2i:
	if cells.is_empty():
		return Vector2i.ZERO
	var center = tilemap.get_used_rect().get_center()
	var placement = cells[0]
	for cell in cells:
		if (cell - center).length_squared() > (placement - center).length_squared():
			placement = cell
	var exit = EXIT.instantiate()
	exit.enemies_gone = not with_enemies
	exit.global_position = tilemap.map_to_local(placement)
	if is_boss:
		exit.override_wait = 38.4
		exit.arrived.connect(world._on_exit_arrived)
	exit.moved.connect(_on_exit_moved.bind(next_gen_type))
	world.add_child.call_deferred(exit)
	return placement

func place_pickups(cells: Array[Vector2i]):
	var clone = cells.duplicate()
	var placement = clone.pop_at(rng.randi() % clone.size())
	while placement + Vector2i.LEFT in clone and placement + Vector2i.RIGHT in clone and not clone.is_empty():
		placement = clone.pop_at(rng.randi() % clone.size())
	
	var gun = Global.weapon_pool["gun"].pick_random().new()
	var melee = Global.weapon_pool["melee"].pick_random().new()
	var gun_pickup = Box.new(gun)
	var melee_pickup = Box.new(melee)
	gun_pickup.global_position = placement
	melee_pickup.global_position = placement + Vector2i.RIGHT
	world.add_child.call_deferred(gun_pickup)
	world.add_child.call_deferred(melee_pickup)

func place_npcs(cells: Array[Vector2i], taken_positions: Array[Vector2i]):
	var dialogues: Array = Global.DIALOGUES.get(Global.current_area, []).duplicate()
	
	var clone = cells.duplicate()
	var positions = []
	for i in range(3):
		if not clone.is_empty():
			var j = rng.randi() % clone.size()
			for pos in taken_positions:
				while tilemap.get_cell_source_id(1, clone[j]) != -1 or (clone[j] - pos).length() < 3:
					clone.remove_at(j)
					j = rng.randi() % clone.size()
			positions.append(clone.pop_at(j))
	for pos in positions:
		if dialogues.is_empty():
			continue
		var npc = NPC.instantiate()
		npc.global_position = tilemap.map_to_local(pos)
		npc.lines = dialogues.pop_at(rng.randi() % dialogues.size())
		world.add_child.call_deferred(npc)

func place_vending(cells: Array[Vector2i], taken_positions: Array[Vector2i]):
	var clone = cells.duplicate()
	var j = rng.randi() % clone.size()
	for pos in taken_positions:
		while abs(clone[j].x - pos.x) < 4:
			clone.remove_at(j)
			j = rng.randi() % clone.size()
	var vending = VENDING.instantiate()
	vending.global_position = tilemap.map_to_local(clone[j])
	world.add_child.call_deferred(vending)
	return clone[j]

func place_props(cells: Array[Vector2i]):
	var sum = Vector2i.ZERO
	for cell in cells:
		sum += cell
	var position = sum / cells.size()
	
	var tree = TREE.instantiate()
	tree.global_position = tilemap.map_to_local(position)
	world.add_child.call_deferred(tree)
	return [position]

func place_poles(cells: Array[Vector2i], taken_positions: Array[Vector2i]):
	var clone = cells.duplicate()
	var pos_clone = taken_positions.duplicate()
	var pole_positions: Array[Vector2i] = []
	var count = 3
	if Global.current_area == Area.City:
		count = 5
	for i in range(count):
		var j = rng.randi() % clone.size()
		for pos in pos_clone:
			while (clone[j] - pos).length_squared() < 16:
				clone.remove_at(j)
				j = rng.randi() % clone.size()
		pole_positions.append(clone[j])
		pos_clone.append(clone[j])
	for pos in pole_positions:
		var prop
		if Global.current_area == Area.Sky:
			if rng.randf() >= 0.5:
				prop = POLE.instantiate()
			else:
				prop = TURBINE.instantiate()
		else:
			prop = LAMP.instantiate()
		prop.global_position = tilemap.map_to_local(pos)
		world.add_child.call_deferred(prop)
	return pole_positions

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
			player.light.show()
			world.get_node("SkyBG").hide()
			world.get_node("SkyModulate").hide()
			world.get_node("CityBG").show()
			world.get_node("CityModulate").show()
		Area.Abyss:
			player.light.show()
			world.get_node("SkyBG").hide()
			world.get_node("SkyModulate").hide()
			world.get_node("CityBG").hide()
			world.get_node("CityModulate").hide()
			world.get_node("AbyssBG").show()
			world.get_node("AbyssModulate").show()
			
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

func _on_exit_moved(next_gen_type: GenerationType):
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
			world.fade_music_out(10)
			generate_town()
		GenerationType.Finale:
			cleanup()
			world.init_finale()

func _on_enemy_dead():
	if boss:
		return
	enemies_left -= 1
	if enemies_left == 0:
		var exit = get_tree().get_first_node_in_group("exit")
		exit.enemies_gone = true
		await get_tree().create_timer(0.5).timeout
		exit.play_fin_sound()
		var check = CHECK.instantiate()
		check.restart()
		check.global_position = player.global_position + Vector2(4, -4)
		world.add_child(check)
		world.transition_music("%s_intense" % AREA_NAMES[Global.current_area], "%s_calm" % AREA_NAMES[Global.current_area])
		player.change_emotion(Player.Emotion.Correct)
