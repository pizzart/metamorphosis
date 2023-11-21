class_name Upgrade
extends Node

var weight: int
@onready var player: Player = get_parent()

func _init():
	add_to_group("upgrade")
