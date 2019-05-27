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
		player.get_node("SFX_Take_Item").play()
		can_area = true
		get_tree().get_nodes_in_group("Main")[0].Show_Hide_Key()
		queue_free()
