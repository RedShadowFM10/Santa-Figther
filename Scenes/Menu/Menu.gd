extends Control

func _ready():
	get_tree().paused = false

# Boton de play
func _on_Play_pressed():
	Hide_Show()

# Boton de salir
func _on_Exit_Game_pressed():
	get_tree().quit()

func Hide_Show():
	$Tittle.visible = !$Tittle.visible
	$Play.visible = !$Play.visible
	$Exit_Game.visible = !$Exit_Game.visible
	$Version.visible = !$Version.visible
	$Back.visible = !$Back.visible
	$Levels.visible = !$Levels.visible

#1 Boton de regreso
func _on_Back_pressed():
	$Back.modulate = Color(1, 1, 1)
	Hide_Show()

#2
func _on_Back_mouse_entered():
	$Back.modulate = Color("737373")

#3
func _on_Back_mouse_exited():
	$Back.modulate = Color(1, 1, 1)
