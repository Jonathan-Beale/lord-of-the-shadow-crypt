class_name EnemyPunchState
extends EnemyAttackState

func enter():
	super()
	enemy.animation.play(punch_anim)
	enemy.animation.animation_finished.connect(func(_anim): has_attacked = true)
	attacking = false
