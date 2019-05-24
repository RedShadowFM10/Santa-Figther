extends Button

func _on_Level_Type_pressed():
	if name == "01":
		Global.level = name
		Global.Powers()
		Fade_In_Out.change_scene("res://Scenes/Intro/Intro.tscn")
	elif name == "02":
		Global.level = name
		Global.Powers()
		Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
