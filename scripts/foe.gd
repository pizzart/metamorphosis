class_name Foe
extends CharacterBody2D

var health: int

var sprite: AnimatedSprite2D
var rng = RandomNumberGenerator.new()
@onready var player = get_tree().get_first_node_in_group("player")

func hit(damage: int, force: Vector2):
	pass

func die():
	pass
