extends Node2D

@onready var last_mouse_position = Vector2.ZERO
@onready var cam = $Camera2D
@export var pan_sensitivity = 0.2

func _input(event):
	if event is InputEventMouseMotion:
		var delta = last_mouse_position - event.position
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(cam, "position", cam.position + delta * pan_sensitivity, 0.1)
		last_mouse_position = event.position


var title = "LIM WEI JEN"
var is_ready = false

func _ready():
	await get_tree().create_timer(0.5).timeout
	var text = ""
	for c in title:
		text += c
		$Parallax2D7/Label.text = text
		$Parallax2D8/Label.text = text
		await get_tree().create_timer(0.1).timeout
	button_player.play("show button")
	await button_player.animation_finished
	is_ready = true


@onready var button_player = $Parallax2D9/AnimationPlayer
func _on_button_mouse_entered():
	if is_ready:
		button_player.play("mouse in")

func _on_button_mouse_exited():
	if is_ready:
		button_player.play_backwards("mouse in")


func _on_button_pressed():
	$CanvasLayer/AnimationPlayer.play("show notice")

func _on_ready_button_pressed():
	$CanvasLayer/AnimationPlayer.play_backwards("new_animation")
	await $CanvasLayer/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://chapters/chapter 1/chapter_1.tscn")
