extends Control

func _ready():
	get_tree().paused = false
	Global.intro = true

# Boton de play
func _on_Play_pressed():
	Hide_Show(1)

# Boton de los creditos
func _on_Credits_Button_pressed():
	Hide_Show(2)

# Boton de salir
func _on_Exit_Game_pressed():
	get_tree().quit()

func Hide_Show(kind):
	$Tittle.visible = !$Tittle.visible
	$Play.visible = !$Play.visible
	$Credits_Button.visible = !$Credits_Button.visible
	$Exit_Game.visible = !$Exit_Game.visible
	$Version.visible = !$Version.visible
	$Back.visible = !$Back.visible
	if kind == 1:
		$Levels.visible = !$Levels.visible
	elif kind == 2:
		$Credits.visible = !$Credits.visible

#1 Boton de regreso
func _on_Back_pressed():
	$Back.modulate = Color(1, 1, 1)
	if $Levels.visible:
		Hide_Show(1)
	elif $Credits.visible:
		Hide_Show(2)

#2
func _on_Back_mouse_entered():
	$Back.modulate = Color("737373")

#3
func _on_Back_mouse_exited():
	$Back.modulate = Color(1, 1, 1)
