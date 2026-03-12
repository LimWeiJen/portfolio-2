extends TextureButton

@export var mute_texture: Texture2D
@export var unmute_texture: Texture2D

func _ready():
	if is_muted(): set_texture(unmute_texture)
	else: set_texture(mute_texture)

func _on_pressed():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), not is_muted())
	if is_muted(): set_texture(unmute_texture)
	else: set_texture(mute_texture)

func is_muted():
	return AudioServer.is_bus_mute(AudioServer.get_bus_index("Master"))

func set_texture(texture: Texture2D):
	texture_normal = texture
	texture_hover = texture
	texture_pressed = texture
	texture_disabled = texture
	texture_focused = texture
