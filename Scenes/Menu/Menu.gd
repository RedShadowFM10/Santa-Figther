extends Control

func _ready():
	get_tree().paused = false
	Global.intro = true

# Boton de play
func _on_Play_pressed():
	Global.level = "01"
	Global.Powers()
	Fade_In_Out.change_scene("res://Scenes/Intro/Intro.tscn")
#	Hide_Show(1)

# Boton de los creditos
func _on_Credits_Button_pressed():
	Hide_Show(2)

# Boton de salir
func _on_Exit_Game_pressed():
	get_tree().quit()

func Hide_Show(kind):
	if kind == 1:
		$Tittle.visible = !$Tittle.visible
		$Play.visible = !$Play.visible
		$Credits_Button.visible = !$Credits_Button.visible
		$Exit_Game.visible = !$Exit_Game.visible
		$Back.visible = !$Back.visible
		$Levels.visible = !$Levels.visible
		$Version.visible = !$Version.visible
	elif kind == 2:
		$Tittle.visible = !$Tittle.visible
		$Play.visible = !$Play.visible
		$Credits_Button.visible = !$Credits_Button.visible
		$Exit_Game.visible = !$Exit_Game.visible
		$Back.visible = !$Back.visible
		$Credits.visible = !$Credits.visible
		$Asset_Credits.visible = !$Asset_Credits.visible
	elif kind == 3:
		$Credits.visible = !$Credits.visible
		$Asset_Credits.visible = !$Asset_Credits.visible
		$Assets_Credits_Text.visible = !$Assets_Credits_Text.visible

#1 Boton de regreso
func _on_Back_pressed():
	$Back.modulate = Color(1, 1, 1)
	if $Levels.visible:
		Hide_Show(1)
	elif $Credits.visible:
		Hide_Show(2)
	elif $Assets_Credits_Text.visible:
		Hide_Show(3)

#2
func _on_Back_mouse_entered():
	$Back.modulate = Color("737373")

#3
func _on_Back_mouse_exited():
	$Back.modulate = Color(1, 1, 1)

func _on_Asset_Credits_pressed():
	Hide_Show(3)
