class_name PlayerPunchState
extends PlayerAttackState

func enter():
	super()
	player.animation.play(punch_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
