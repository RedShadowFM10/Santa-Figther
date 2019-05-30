extends Control

func _ready():
	$Santa.dead = true
	get_tree().get_nodes_in_group("Main")[0].santa_intro = true

func _on_Menu_pressed():
	Fade_In_Out.change_scene("res://Scenes/Menu/Menu.tscn")
