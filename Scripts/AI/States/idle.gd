class_name EnemyIdleState
extends EnemyState

var idle_timer = 0.0
const IDLE_CHANGE_INTERVAL = 2.0

func enter():
	var enemy = get_owner()
	if enemy.animation != null:
		enemy.animation.play("Idle")
	idle_timer = 0.0

func process_frame(delta: float) -> State:
	var enemy = get_owner()
	idle_timer += delta

	var move_dir = enemy.ai_input.get("move_dir", 0.0)
	var jump = enemy.ai_input.get("jump", false)
	var attack = enemy.ai_input.get("attack", false)
	var kick = enemy.ai_input.get("kick", false)

	if move_dir != 0.0:
		var walk_state = get_parent().get_node("Walk")
		if walk_state != null:
			return walk_state
	elif jump:
		var jump_state = get_parent().get_node("Jump")
		if jump_state != null:
			return jump_state
	elif attack:
		var punch_state = get_parent().get_node("Punch")
		if punch_state != null:
			return punch_state
	elif kick:
		var kick_state = get_parent().get_node("Kick")
		if kick_state != null:
			return kick_state

	return null

func process_physics(delta: float) -> State:
	return null

func exit(new_state = null):
	pass
