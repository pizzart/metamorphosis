extends Node

func generate_intermission():
	$TileMap.clear()
	get_tree().call_group("enemy", "queue_free")
	get_tree().call_group("exit", "queue_free")
	get_tree().call_group("teleporter", "queue_free")
	place_islands(1, INTERMISSION_SIZE)
	place_pickups()
	var exit_placement = place_exit(true)
	place_player(exit_placement)
