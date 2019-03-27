extends Node

# Escena del regalo
export (PackedScene) var Gift
var gift01_02 # variable para el regalo / True 01 / False 02
var gift_direccion # False izquierda / True derecha

func _input(event):
	if(Input.is_action_just_pressed("Esc")):
		if(get_tree().paused == false):
			get_tree().paused = true
		else:
			get_tree().paused = false
	elif(Input.is_action_just_pressed("Enter")):
		get_tree().get_nodes_in_group("Objetos")[0].queue_free()
		get_tree().reload_current_scene()

func Gift_Instaciar(var tipo_gift, var posicion, var direccion):
	var NewGift = Gift.instance()
	if(tipo_gift):
		gift01_02 = true
		get_tree().get_nodes_in_group("Objetos")[0].add_child(NewGift)
		NewGift.global_position = posicion
	else:
		gift01_02 = false
		gift_direccion = direccion
		get_tree().get_nodes_in_group("Objetos")[0].add_child(NewGift)
		NewGift.global_position = posicion
