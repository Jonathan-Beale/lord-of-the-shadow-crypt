class_name EnemyPunchState
extends EnemyState

const PUNCH_DURATION = 0.35
var timer = 0.0

func enter():
	var enemy = get_owner()
	if not enemy.is_on_floor():
		return get_parent().get_node("Fall")
	if enemy.animation != null:
		enemy.animation.play("Punch")
	timer = 0.0

func process_frame(delta: float) -> State:
	timer += delta
	if timer >= PUNCH_DURATION:
		var walk_state = get_parent().get_node("Walk")
		if walk_state != null:
			return walk_state
	return null

func process_physics(delta: float) -> State:
	return null

func exit(new_state = null):
	pass
