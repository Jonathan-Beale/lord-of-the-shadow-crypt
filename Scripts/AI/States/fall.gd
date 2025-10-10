extends State

var gravity = 1200
var fall_state_target_y = 50

func enter() -> Variant:
	var enemy = owner
	if enemy.animation:
		enemy.animation.play("fall")
	return null

func process_frame(delta: float) -> State:
	var enemy = owner

	enemy.velocity.y += gravity * delta
	enemy.move_and_slide()

	if "move_dir" in enemy.ai_input:
		enemy.velocity.x = enemy.ai_input["move_dir"] * enemy.speed
	else:
		enemy.velocity.x = 0

	if enemy.global_position.y >= fall_state_target_y:
		enemy.global_position.y = fall_state_target_y
		enemy.velocity.y = 0
		
		var walk_state = null
		if get_parent().has_node("Walk"):
			walk_state = get_parent().get_node("Walk")
		if walk_state != null:
			return walk_state

	return null

func exit(next_state: State = null) -> Variant:
	return null
