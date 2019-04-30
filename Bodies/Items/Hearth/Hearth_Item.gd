extends KinematicBody2D

var move = Vector2()
var gravity = 600

var can_area = false

var player

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	move.y = -250
	move = move_and_slide(move)

func _physics_process(delta):
	if !is_on_floor():
		move.y += gravity * delta
	else:
		move.y = 0
		if $Area2D/CollisionShape2D.disabled:
			$Area2D/CollisionShape2D.disabled = false
	
	move = move_and_slide(move, Vector2(0, -1))

func _on_Area2D_area_entered(area):
	if area.is_in_group("Player") && !can_area:
		player.Add_Lives()
		can_area = true
		queue_free()

func _on_Timer_timeout():
	queue_free()
