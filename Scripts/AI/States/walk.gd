class_name EnemyWalkState
extends EnemyState

const BASE_SPEED = 120.0
const EDGE_LEFT = -180.0
const EDGE_RIGHT = 180.0

func enter():
	var enemy = get_owner()
	if not enemy.is_on_floor():
		return get_parent().get_node("Fall")
	if enemy.animation != null:
		enemy.animation.play("Walk")

func process_frame(delta: float) -> State:
	var enemy = get_owner()

	var move_dir = enemy.ai_input.get("move_dir", 0.0)
	var jump = enemy.ai_input.get("jump", false)
	var attack = enemy.ai_input.get("attack", false)
	var kick = enemy.ai_input.get("kick", false)

	if move_dir == 0.0:
		var idle_state = get_parent().get_node("Idle")
		if idle_state != null:
			return idle_state

	if jump:
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
	var enemy = get_owner()
	var move_dir = enemy.ai_input.get("move_dir", 0.0)
	var speed = BASE_SPEED

	var next_x = enemy.global_position.x + move_dir * speed * delta
	if next_x < EDGE_LEFT:
		next_x = EDGE_LEFT
	elif next_x > EDGE_RIGHT:
		next_x = EDGE_RIGHT

	enemy.global_position.x = next_x

	if enemy.sprite != null:
		if move_dir > 0:
			enemy.sprite.flip_h = false
		elif move_dir < 0:
			enemy.sprite.flip_h = true

	return null

func exit(new_state = null):
	pass
