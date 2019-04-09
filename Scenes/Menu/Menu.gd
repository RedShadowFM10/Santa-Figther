extends Node

func _ready():
	get_tree().paused = false

# Boton de play
func _on_Play_pressed():
	get_tree().change_scene("res://Scenes/Main/Main.tscn")

# Boton de controles
func _on_Controls_pressed():
	$Back.visible = true
	$Tittle.visible = false
	$Play.visible = false
	$Controls.visible = false
	$Controls_Info.visible = true
	$Exit_Game.visible = false

# Boton de salir
func _on_Exit_Game_pressed():
	get_tree().quit()

#1 Boton de regreso
func _on_Back_pressed():
	$Back.modulate = Color(1, 1, 1)
	$Back.visible = false
	$Tittle.visible = true
	$Play.visible = true
	$Controls.visible = true
	$Controls_Info.visible = false
	$Exit_Game.visible = true

#2
func _on_Back_mouse_entered():
	$Back.modulate = Color(0, 0, 0)

#3
func _on_Back_mouse_exited():
	$Back.modulate = Color(1, 1, 1)
