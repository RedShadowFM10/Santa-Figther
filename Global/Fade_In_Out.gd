extends CanvasLayer

func change_scene(scene):
	$AnimationPlayer.play("Fade_In")
	yield($AnimationPlayer, "animation_finished")
	get_tree().change_scene(scene)
	$AnimationPlayer.play("Fade_Out")

func reload_scene():
	$AnimationPlayer.play("Fade_In")
	yield($AnimationPlayer, "animation_finished")
	get_tree().reload_current_scene()
	$AnimationPlayer.play("Fade_Out")
