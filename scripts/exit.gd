class_name Exit
extends Area2D

signal moved
var counter: int
var can_interact: bool
var enemies_gone: bool
@onready var player: Player = get_tree().get_first_node_in_group("player")

func _ready():
	end_descent()

func start_descent():
	can_interact = false
	set_deferred("monitoring", false)
	player.can_move = false
	player.global_position = global_position
	player.sprite.animation = "front"
	player.sprite.pause()
	player.change_emotion(Player.Emotion.Waiting)
	var tween = create_tween().set_parallel()
	tween.tween_property(self, "global_position", global_position + Vector2(0, 50), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(player, "global_position", global_position + Vector2(0, 50), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(UI.transition_in)
	tween.tween_property(self, "global_position", global_position + Vector2(0, 200), 1.0)
	tween.tween_property(player, "global_position", global_position + Vector2(0, 200), 1.0)
	await tween.finished
	player.can_move = true
	player.change_emotion(Player.Emotion.None)
	player.sprite.play()
	moved.emit()

func end_descent():
	var end_position = global_position
	global_position = end_position - Vector2(0, 200)
	player.can_move = false
	player.global_position = global_position
	player.sprite.animation = "front"
	player.sprite.pause()
	player.change_emotion(Player.Emotion.Waiting)
	var tween = create_tween().set_parallel()
	tween.tween_callback(UI.transition_out)
	tween.tween_property(self, "global_position", end_position - Vector2(0, 50), 1.0)
	tween.tween_property(player, "global_position", end_position - Vector2(0, 50), 1.0)
	tween.chain().tween_property(self, "global_position", end_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "global_position", end_position, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await tween.finished
	set_deferred("monitoring", true)
	$Timer.start()
	player.can_move = true
	player.change_emotion(Player.Emotion.None)
	player.sprite.play()

func _input(event):
	if event.is_action_pressed("use"):
		if can_interact:
			start_descent()
		elif overlaps_body(player):
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
