extends Button

func _on_Level_Type_pressed():
	Global.level = name
	Global.Powers()
	Fade_In_Out.change_scene("res://Scenes/Main/Main.tscn")
