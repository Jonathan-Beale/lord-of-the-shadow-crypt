class_name PlayerBlockState
extends PlayerState

# Block modifiers
const DAMAGE_REDUCTION := 0.75  # 75% damage reduction
const KNOCKBACK_REDUCTION := 0.75  # 75% knockback reduction

func enter():
	# Stop movement immediately
	player.velocity = Vector2.ZERO
	
	# Play block animation
	if player.animation.has_animation("Block"):
		player.animation.play("Block")
	else:
		print("Warning: 'Block' animation not found!")

	print("Entered Block state")

func process_frame(delta: float):
	# Exit block when button released
	if not Input.is_action_pressed(player.controls.block):
		return idle_state
	return null

func process_input(event: InputEvent) -> State:
	# Ignore all movement/attack input while blocking
	return null

func process_physics(delta: float) -> State:
	# Lock player completely
	player.velocity = Vector2.ZERO
	player.move_and_slide()
	return null

func exit(new_state: State = null):
	print("Exited Block state")
	return new_state

# --- Damage mitigation helpers ---
func mitigate_damage(amount: float) -> float:
	return amount * (1.0 - DAMAGE_REDUCTION)

func mitigate_knockback(force: Vector2) -> Vector2:
	return force * (1.0 - KNOCKBACK_REDUCTION)
