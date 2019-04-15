extends Control

var count = 0

func _ready():
	$Santa.get_node("AnimatedSprite").playing = true
	$Santa.dead = true

func _on_Timer_timeout():
	count += 1
	if count == 1:
		$Timer.wait_time = 10
		$Timer.start()
		$Instructions.set_text("PRESS W, A, S, D\nAND\nTHE ARROWS TO MOVE")
		$Santa.dead = false
	if count == 2:
		$Instructions.queue_free()
		count = 0
