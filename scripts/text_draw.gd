class_name TextDraw
extends Node2D

const FONT = preload("res://misc/font.png")
var text: String

func _init():
	z_index = 4

func _draw():
	draw_string(FONT, Vector2.ZERO, text)
