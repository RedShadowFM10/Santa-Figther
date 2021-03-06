extends Node

# Escena del regalo
export (PackedScene) var gift
var gift01_02 # variable para el regalo / True 01 / False 02
var gift_direction # False izquierda / True derecha

var santa_dead = false
var santa_intro = false

var timers
var level

func _ready():
	get_tree().paused = false
	level = Global.level
	var level_type = load("res://Scenes/Levels/"+Global.level+".tscn")
	var new_level = level_type.instance()
	
	var music_type
	var new_music
	if Global.level == "01" || "1,1":
		music_type = load("res://Sounds/Music/Beat&em_Up_Level/Music_Level.tscn")
		new_music = music_type.instance()
	
	call_deferred("add_child", new_level)
	$Music.call_deferred("add_child", new_music)

func _input(_event):
	if Input.is_action_just_pressed("Esc") && !santa_dead && !santa_intro:
		get_tree().paused = !get_tree().paused
		$GUI/Full_Screen.visible = !$GUI/Full_Screen.visible
		$GUI/Retry.visible = !$GUI/Retry.visible
		$GUI/Menu.visible = !$GUI/Menu.visible
		$GUI/Pause.visible = !$GUI/Pause.visible
	elif Input.is_action_just_pressed("Enter") && $GUI/Menu.visible && !santa_intro:
		timers = get_tree().get_nodes_in_group("Timer")
		for timer in timers:
			timer.stop()
		$GUI/Full_Screen.visible = false
		Fade_In_Out.reload_scene()
		santa_intro = true

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
	santa_intro = true
	Fade_In_Out.change_scene("res://Scenes/Menu/Menu.tscn")

func _on_Retry_pressed():
	santa_intro = true
	Fade_In_Out.reload_scene()

func Santa_Dead():
	if !santa_dead:
		santa_dead = true
		$Timer.start()

func Next_Level():
	$GUI/Level_Complete.visible = true
	$GUI/Next_Level.visible = true
	$GUI/Menu.visible = true
	$GUI/Full_Screen.visible = true
	santa_intro = true

func _on_Timer_timeout():
	$GUI/Full_Screen.visible = true
	$GUI/Retry.visible = true
	$GUI/Menu.visible = true

func Deleted_Add_Child():
	get_node(level).queue_free()
	level = Global.level
	var level_type = load("res://Scenes/Levels/"+Global.level+".tscn")
	var new_level = level_type.instance()
	call_deferred("add_child", new_level)

func Show_Key():
	$GUI/Key.visible = true

func Hide_Key():
	$GUI/Key.visible = false

func _on_Next_Level_pressed():
	Fade_In_Out.effect_change_level()
	$GUI/Next_Level/Timer_Next_Level.start()

func _on_Timer_Next_Level_timeout():
	Deleted_Add_Child()
	$GUI/Level_Complete.visible = false
	$GUI/Next_Level.visible = false
	$GUI/Menu.visible = false
	$GUI/Full_Screen.visible = false
