extends Area2D

@export_multiline var dialogue: Array[String]
@export var multiple_labels: Array[Label]
@export var max_text_length = 10

@onready var player: Player = get_parent().get_node("player")
@onready var animated_sprite = $Sprite2D

var player_is_within_range: bool = false
var player_is_interacting: bool = false

func _ready():
	hide_all_npc_labels()

func _process(_delta):
	if Input.is_action_just_pressed("interact") and player_is_within_range and not player_is_interacting:
		player_is_interacting = true
		await start_dialogue()
		player_is_interacting = false

func start_dialogue():
	player.hide_interact_sign()
	for line in dialogue:
		if line.begins_with("p:"):
			await player_speak(line.get_slice(":", 1))
		elif line.begins_with("anim:"):
			await play_animation(line.get_slice(":", 1))
		elif line.contains(":"):
			await npc_speak(line.get_slice(":", 1), int(line.get_slice(":", 0)))
		else:
			await npc_speak(line)
	player.dialogue_label.text = ""
	hide_all_npc_labels()
	player.dialogue_label.visible = false

func play_animation(anim_name: String):
	animated_sprite.play(anim_name)
	if not (animated_sprite.sprite_frames as SpriteFrames).get_animation_loop(anim_name):
		await animated_sprite.animation_finished

func player_speak(line: String):
	player.dialogue_label.text = ""
	hide_all_npc_labels()
	player.dialogue_label.visible = true
	for c in line:
		player.dialogue_label.text += c
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(1.0).timeout

func npc_speak(line: String, label_no = 0):
	player.dialogue_label.text = ""
	var label = multiple_labels[label_no]
	label.text = ""
	label.visible = true
	player.dialogue_label.visible = false
	var curr_text_length = 0
	for c in line:
		if c == " ":
			curr_text_length += 1
		label.text += c
		if curr_text_length > max_text_length:
			label.text += "\n"
			curr_text_length = 0
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(1.0).timeout
	hide_all_npc_labels()

func hide_all_npc_labels():
	for label in multiple_labels:
		label.text = ""
		label.visible = false

func _on_body_entered(body: Node2D):
	if body is Player and not player_is_interacting:
		player_is_within_range = true
		body.show_interact_sign()

func _on_body_exited(body: Node2D):
	if body is Player and not player_is_interacting:
		player_is_within_range = false
		body.hide_interact_sign()
