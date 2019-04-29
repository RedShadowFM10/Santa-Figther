extends Button

func _on_Level_Type_pressed():
	if name == "01":
		Fade_In_Out.change_scene("res://Scenes/Intro/Intro.tscn")
	else:
		Global.level = name
		Global.Powers()
		Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
