extends Control

var equipped_item: int = 0
var equipped_hat: int = Global.equipped_hat

func _ready():
	UI.hide()

func _on_hat_toggled(button_pressed):
	$Hats/List.clear()
	$Hats/List.add_icon_item(Global.HATS[0][2])
	Global.unlocked_hats.sort()
	for hat in Global.unlocked_hats:
		$Hats/List.add_icon_item(Global.HATS[hat][2])
	$Hats/List.select(equipped_hat)
	
	$Hats/List.visible = button_pressed

func _on_item_toggled(button_pressed):
	Global.unlocked_items.sort()
	$Items/List.visible = button_pressed

func _on_go_pressed():
	Global.equipped_hat = equipped_hat
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_item_list_item_selected(index):
	equipped_item = index
	$Items/Button.icon = Global.ITEMS[index][1]

func _on_hat_list_item_selected(index):
	equipped_hat = index
	$HatTexture.visible = index != 0
	$HatTexture.texture = Global.HATS[index][1]
	$Hats/Button.icon = Global.HATS[index][2]

func _on_shop_window_close_requested():
	$ShopWindow.hide()

func _on_shop_pressed():
	$Hats/Button.toggled.emit(false)
	$Items/Button.toggled.emit(false)
	$ShopWindow.visible = not $ShopWindow.visible
