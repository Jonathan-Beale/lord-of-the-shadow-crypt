class_name PlayerKickState
extends PlayerAttackState

func enter():
	super()
	player.animation.play(kick_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
