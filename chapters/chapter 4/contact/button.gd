extends Button

@export var link: String = "https://google.com"

func _ready():
	connect("mouse_entered", enlarge)
	connect("mouse_exited", deenlarge)

func enlarge():
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)

func deenlarge():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.1)

func _on_pressed():
	OS.shell_open(link)
