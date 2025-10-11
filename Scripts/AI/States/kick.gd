class_name EnemyKickState
extends EnemyState

const KICK_DURATION = 0.4
var timer = 0.0

func enter():
	var enemy = get_owner()
	if enemy.animation != null:
		enemy.animation.play("Kick")
	timer = 0.0

func process_frame(delta: float) -> State:
	timer += delta
	if timer >= KICK_DURATION:
		var walk_state = get_parent().get_node("Walk")
		if walk_state != null:
			return walk_state
	return null

func process_physics(delta: float) -> State:
	var enemy = get_owner()
	var dir = 1.0
	if enemy.sprite != null and enemy.sprite.flip_h == true:
		dir = -1.0
	enemy.global_position.x += dir * 25.0 * delta
	return null

func exit(new_state = null):
	pass
