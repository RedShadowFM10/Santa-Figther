extends Button

func _on_Level_Type_pressed():
	Global.level = name
	Global.Powers()
	get_tree().change_scene("res://Scenes/Main/Main.tscn")
