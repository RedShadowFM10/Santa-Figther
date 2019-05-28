extends Node

var intro = false

var level = "1,1"

var gui_gift = true

var can_punch = true
var can_super_attack = true
var can_kick = true
var can_gift = true

func Powers():
	if level == "01":
		gui_gift = false
		can_punch = false
		can_super_attack = false
		can_kick = false
		can_gift = false
	elif level == "02":
		pass
