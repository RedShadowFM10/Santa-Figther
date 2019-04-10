extends Node

var level = ""

var can_punch = false
var can_super_attack = false
var can_kick = false
var can_gift = false

func Powers():
	if level == "01":
		can_punch = false
		can_super_attack = false
		can_kick = false
		can_gift = false
	elif level == "02":
		pass
