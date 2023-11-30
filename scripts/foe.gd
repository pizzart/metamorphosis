class_name Foe
extends CharacterBody2D

signal dead

var health: int

var sprite: AnimatedSprite2D
var rng = Global.rng
@onready var player = get_tree().get_first_node_in_group("player")

func _init():
	add_to_group("foe")

func hit(_damage: int, _force: Vector2):
	pass

func die():
	dead.emit()
