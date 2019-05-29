extends KinematicBody2D

var move = Vector2()
var gravity = 600

var can_area = false

var player

func _ready():
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
		player.key = true
		can_area = true
		get_tree().get_nodes_in_group("Main")[0].Show_Key()
		get_tree().get_nodes_in_group("Door")[0].get_node("Open").visible = true
		get_tree().get_nodes_in_group("Door")[0].get_node("Closed").visible = false
		queue_free()

func _on_Ready_timeout():
	player = get_tree().get_nodes_in_group("Player")[0]
