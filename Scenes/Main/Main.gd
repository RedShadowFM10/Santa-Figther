extends Node

# Escena del regalo
export (PackedScene) var gift
var gift01_02 # variable para el regalo / True 01 / False 02
var gift_direction # False izquierda / True derecha

var santa_dead = false

func _ready():
	get_tree().paused = false
	var level_type = load("res://Scenes/Levels/"+Global.level+".tscn")
	var new_level = level_type.instance()
	call_deferred("add_child", new_level)

func _input(_event):
	if Input.is_action_just_pressed("Esc") && !santa_dead:
		get_tree().paused = !get_tree().paused
		$GUI/Full_Screen.visible = !$GUI/Full_Screen.visible
		$GUI/Retry.visible = !$GUI/Retry.visible
		$GUI/Menu.visible = !$GUI/Menu.visible
		$GUI/Pause.visible = !$GUI/Pause.visible
	elif Input.is_action_just_pressed("Enter"):
		$GUI/Full_Screen.visible = false
		get_tree().reload_current_scene()

func Gift_Instaciar(kind_gift, position, direction):
	var new_gift = gift.instance()
	if(kind_gift):
		gift01_02 = true
		get_tree().get_nodes_in_group("Level")[0].add_child(new_gift)
		new_gift.global_position = position
	else:
		gift01_02 = false
		gift_direction = direction
		get_tree().get_nodes_in_group("Level")[0].add_child(new_gift)
		new_gift.global_position = position

# Ir al menu
func _on_Menu_pressed():
	get_tree().change_scene("res://Scenes/Menu/Menu.tscn")

func _on_Retry_pressed():
	get_tree().reload_current_scene()

func Santa_Dead():
	santa_dead = true
	yield(get_tree().create_timer(2), "timeout")
	$GUI/Full_Screen.visible = true
	$GUI/Retry.visible = true
	$GUI/Menu.visible = true
