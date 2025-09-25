class_name EnemyIdleState
extends EnemyState

func enter():
	enemy.animation.play(idle_anim)

func exit(new_state: State = null):
	super(new_state)

func process_physics(delta: float) -> State:
	
	return null
