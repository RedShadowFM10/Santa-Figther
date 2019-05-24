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

func effect():
	$AnimationPlayer.play("Fade_In")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Fade_Out")

func effect_change_level():
	$AnimationPlayer.play("Fade_In_02")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Fade_Out")
