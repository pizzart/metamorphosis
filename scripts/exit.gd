class_name Exit
extends Area2D

signal moved

const WAIT_TIME = 0.8

var counter: int
var can_interact: bool
var enemies_gone: bool
var timer: float
@export var long: bool

@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready():
	end_descent()

func _process(delta):
	if Input.is_action_pressed("use") and can_interact:
		timer += delta
		UI.set_progress(timer / WAIT_TIME)
		if timer >= WAIT_TIME:
			timer = 0
			start_descent()
	else:
		timer = 0
		UI.set_progress(timer / WAIT_TIME)

func start_descent():
	can_interact = false
	set_deferred("monitoring", false)
	player.can_move = false
	player.global_position = global_position
	player.sprite.animation = "front"
	player.sprite.pause()
	player.change_emotion(Player.Emotion.Waiting)
	$Start.play()
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "global_position", global_position + Vector2(0, 50), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(player, "global_position", global_position + Vector2(0, 50), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(UI.transition_in)
	tween.tween_callback($Loop.play)
	tween.tween_property(self, "global_position", global_position + Vector2(0, 200), 1.0)
	tween.tween_property(player, "global_position", global_position + Vector2(0, 200), 1.0)
	await tween.finished
	player.can_move = true
	player.change_emotion(Player.Emotion.None)
	player.sprite.play()
	moved.emit()

func end_descent():
	var end_position = global_position
	if long:
		global_position = end_position - Vector2(0, 1000)
	else:
		global_position = end_position - Vector2(0, 200)
	player.can_move = false
	player.global_position = global_position
	player.sprite.animation = "front"
	player.sprite.pause()
	player.change_emotion(Player.Emotion.Waiting)
	$Loop.play()
	var tween = create_tween().set_parallel()
	tween.tween_callback(UI.transition_out)
	var time = 1.0
	if long:
		time = 5.0
	tween.tween_property(self, "global_position", end_position - Vector2(0, 50), time)
	tween.tween_property(player, "global_position", end_position - Vector2(0, 50), time)
	tween.chain().tween_callback($Loop.stop)
	tween.tween_callback($End.play)
	tween.tween_property(self, "global_position", end_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "global_position", end_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	set_deferred("monitoring", true)
	$Timer.start()
	player.can_move = true
	player.change_emotion(Player.Emotion.None)
	player.sprite.play()

func _input(event):
	if event.is_action_pressed("use"):
#		if can_interact:
#			start_descent()
		if not can_interact and overlaps_body(player):
			$ErrorSFX.play()

func _on_body_entered(_body):
	counter += 1
	if counter > 1 and enemies_gone:
		can_interact = true
		UI.show_help()

func _on_body_exited(_body):
	can_interact = false
	UI.hide_help()

func _on_timer_timeout():
	if overlaps_body(player) and enemies_gone:
		can_interact = true
		UI.show_help()
