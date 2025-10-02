extends Button

@export var link: String = "https://google.com"

func _on_pressed():
	OS.shell_open(link)

func _on_mouse_entered():
	Input.set_default_cursor_shape(Input.CURSOR_BUSY)

func _on_mouse_exited():
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
