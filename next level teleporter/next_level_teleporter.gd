extends Area2D

@export var mute_volume = -50
@export var next_level_scene: PackedScene
var player_is_within_range: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("interact") and player_is_within_range:
		$AnimationPlayer.play("fade in")
		await $AnimationPlayer.animation_finished
		_turn_down_volume()
		await get_tree().create_timer(4).timeout
		get_tree().change_scene_to_packed(next_level_scene)


func _on_body_entered(body: Node2D):
	if body is Player:
		player_is_within_range = true
		body.show_interact_sign()

func _on_body_exited(body: Node2D):
	if body is Player:
		player_is_within_range = false
		body.hide_interact_sign()

func _turn_down_volume():
	var t = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	t.tween_property(get_parent().get_node("AudioStreamPlayer"), "volume_db", mute_volume, 3)
	var t2 = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
	t2.tween_property(get_parent().get_node("AudioStreamPlayer2"), "volume_db", mute_volume, 3)