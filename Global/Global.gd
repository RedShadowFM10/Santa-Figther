extends Node

var intro = true

var level = "01"

var gui_gift = false

var can_punch = false
var can_super_attack = false
var can_kick = false
var can_gift = false

func Powers():
	if level == "01":
		gui_gift = false
		can_punch = false
		can_super_attack = false
		can_kick = false
		can_gift = false
	elif level == "02":
		pass
