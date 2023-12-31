class_name Interactable
extends Area2D

var inside: bool
var can_interact: bool
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _init():
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	add_to_group("interactable")
	add_to_group("cleanup")

func _on_body_entered(_body):
#	for i in get_tree().get_nodes_in_group("interactable"):
#		if i != self:
#			i.unfocus()
#	can_interact = true
	if player.can_move:
		inside = true
		UI.show_help()

func _on_body_exited(_body):
	inside = false
	unfocus()

func unfocus():
#	can_interact = false
	UI.hide_help()
