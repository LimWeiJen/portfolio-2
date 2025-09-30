extends Area2D

@export var next_level_scene: PackedScene
var player_is_within_range: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("interact") and player_is_within_range:
		$AnimationPlayer.play("fade in")
		await $AnimationPlayer.animation_finished
		get_tree().change_scene_to_packed(next_level_scene)


func _on_body_entered(body: Node2D):
	if body is Player:
		player_is_within_range = true
		body.show_interact_sign()

func _on_body_exited(body: Node2D):
	if body is Player:
		player_is_within_range = false
		body.hide_interact_sign()
