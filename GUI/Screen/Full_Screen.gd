extends TextureButton

export (Texture) var larger_texture
export (Texture) var smaller_texture

var full_screen

func _ready():
	if OS.is_window_fullscreen():
		set_normal_texture(smaller_texture)
		full_screen = true
	else:
		set_normal_texture(larger_texture)
		full_screen = false

func _on_Full_Screen_pressed():
	if OS.is_window_fullscreen():
		set_normal_texture(larger_texture)
	else:
		set_normal_texture(smaller_texture)
	full_screen = !full_screen
	OS.set_window_fullscreen(full_screen)

func _on_Full_Screen_mouse_entered():
	modulate = Color(0, 0, 0)

func _on_Full_Screen_mouse_exited():
	modulate = Color(1, 1, 1)
