extends Control

var equipped_item: int = Global.equipped_item
var equipped_hat: int = Global.equipped_hat
@onready var previous_size = get_window().size
@onready var previous_pos = get_window().position
@onready var item_list = $SetupWindow/Setup/Items/List
@onready var item_button = $SetupWindow/Setup/Items/Button
@onready var hat_list = $SetupWindow/Setup/Hats/List
@onready var hat_button = $SetupWindow/Setup/Hats/Button
@onready var hat_texture = $SetupWindow/Setup/HatTexture
@onready var click_sfx = $ClickSFX

func _ready():
	UI.hide()
	PauseMenu.can_show = false
	Global.timer = 0
	Global.current_area = Generator.Area.Sky
	Global.set_menu_cursor()
	RenderingServer.global_shader_parameter_set("vignette_opacity", Global.VIGNETTE_OPACITY)
	
	hat_texture.visible = equipped_hat != 0
	hat_texture.texture = Global.HATS[equipped_hat][1]
	hat_button.icon = Global.HATS[equipped_hat][2]
	item_button.icon = Global.ITEMS[equipped_item][1]
	
	get_window().content_scale_size = Vector2i(64, 64)
	get_window().size = Vector2i(196, 196)
	get_window().position += previous_size / 2 - get_window().size / 2

func _on_hat_toggled(button_pressed):
	click_sfx.play()
	hat_list.clear()
	hat_list.add_icon_item(Global.HATS[0][2])
	Global.unlocked_hats.sort()
	for hat in Global.unlocked_hats:
		hat_list.add_icon_item(Global.HATS[hat][2])
	hat_list.select(equipped_hat)
	hat_list.visible = button_pressed

func _on_item_toggled(button_pressed):
	click_sfx.play()
	item_list.clear()
	item_list.add_icon_item(Global.ITEMS[0][1])
	Global.unlocked_items.sort()
	for item in Global.unlocked_items:
		item_list.add_icon_item(Global.ITEMS[item][1])
	item_list.select(equipped_item)
	
	item_list.visible = button_pressed

func _on_go_pressed():
	click_sfx.play()
	Global.equipped_hat = equipped_hat
	Global.equipped_item = equipped_item
	get_window().content_scale_size = Global.WINDOW_SIZE
	get_window().size = previous_size
	get_window().position = previous_pos
	get_tree().change_scene_to_file("res://scenes/world.tscn")

func _on_item_list_item_selected(index):
	click_sfx.play()
	if index != 0:
		equipped_item = Global.unlocked_items[index - 1]
	else:
		equipped_item = 0
	item_button.icon = Global.ITEMS[equipped_item][1]

func _on_hat_list_item_selected(index):
	click_sfx.play()
	if index != 0:
		equipped_hat = Global.unlocked_hats[index - 1]
	else:
		equipped_hat = 0
	hat_texture.visible = index != 0
	hat_texture.texture = Global.HATS[equipped_hat][1]
	item_button.icon = Global.HATS[equipped_hat][2]

func _on_shop_window_close_requested():
	$ShopWindow.hide()

func _on_setup_window_close_requested():
	$SetupWindow.hide()

func _on_shop_pressed():
	click_sfx.play()
	$ShopWindow.visible = not $ShopWindow.visible

func _on_setup_pressed():
	click_sfx.play()
	hat_button.toggled.emit(false)
	item_button.toggled.emit(false)
	$SetupWindow.visible = not $SetupWindow.visible
