extends Control

var equipped_item: int = Global.equipped_item
var equipped_hat: int = Global.equipped_hat

func _ready():
	RenderingServer.global_shader_parameter_set("vignette_opacity", Global.VIGNETTE_OPACITY)
	UI.hide()
	PauseMenu.can_show = false
	Global.timer = 0
	Global.current_area = Generator.Area.Sky
	
	$HatTexture.visible = equipped_hat != 0
	$HatTexture.texture = Global.HATS[equipped_hat][1]
	$Hats/Button.icon = Global.HATS[equipped_hat][2]
	$Items/Button.icon = Global.ITEMS[equipped_item][1]

func _on_hat_toggled(button_pressed):
	$Hats/List.clear()
	$Hats/List.add_icon_item(Global.HATS[0][2])
	Global.unlocked_hats.sort()
	for hat in Global.unlocked_hats:
		$Hats/List.add_icon_item(Global.HATS[hat][2])
	$Hats/List.select(equipped_hat)
	
	$Hats/List.visible = button_pressed

func _on_item_toggled(button_pressed):
	$Items/List.clear()
	$Items/List.add_icon_item(Global.ITEMS[0][1])
	Global.unlocked_items.sort()
	for item in Global.unlocked_items:
		$Items/List.add_icon_item(Global.ITEMS[item][1])
	$Items/List.select(equipped_item)
	
	$Items/List.visible = button_pressed

func _on_go_pressed():
	Global.equipped_hat = equipped_hat
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_item_list_item_selected(index):
	if index != 0:
		equipped_item = Global.unlocked_items[index - 1]
	else:
		equipped_item = 0
	$Items/Button.icon = Global.ITEMS[equipped_item][1]

func _on_hat_list_item_selected(index):
	if index != 0:
		equipped_hat = Global.unlocked_hats[index - 1]
	else:
		equipped_hat = 0
	$HatTexture.visible = index != 0
	$HatTexture.texture = Global.HATS[equipped_hat][1]
	$Hats/Button.icon = Global.HATS[equipped_hat][2]

func _on_shop_window_close_requested():
	$ShopWindow.hide()

func _on_shop_pressed():
	$Hats/Button.toggled.emit(false)
	$Items/Button.toggled.emit(false)
	$ShopWindow.visible = not $ShopWindow.visible
