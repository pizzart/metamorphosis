extends Control

var equipped_item: int = 0
var equipped_hat: int = 0

func _ready():
	for hat in Global.HATS.keys():
		$HatList.add_item(Global.HATS[hat][0])

func _on_hat_toggled(button_pressed):
	$HatList.visible = button_pressed

func _on_item_toggled(button_pressed):
	$ItemList.visible = button_pressed

func _on_go_pressed():
	Global.equipped_hat = equipped_hat
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_item_list_item_selected(index):
	equipped_item = index

func _on_hat_list_item_selected(index):
	equipped_hat = index
	$HatTexture.visible = index != 0
	$HatTexture.texture = Global.HATS[index][1]
