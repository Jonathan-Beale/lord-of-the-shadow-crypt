class_name PlayerDashState
extends PlayerState

const DASH_SPEED := 400.0
const DASH_DURATION := 0.20

var dash_time := 0.0

func enter():
	print("Entered Dash state")
	dash_time = DASH_DURATION

	# Play dash animation if exists
	if player.animation.has_animation("Dash"):
		player.animation.play("Dash")

	# Lock player velocity in dash direction
	var dir = 1 if sprite_flipped else -1
	player.velocity.x = dir * DASH_SPEED
	player.velocity.y = 0  # optional: cancel vertical movement

func process_input(event: InputEvent) -> State:
	# Ignore all input while dashing
	return null

func process_frame(delta: float) -> State:
	dash_time -= delta

	# 👉 NEW: stay in dash until animation fully ends
	if player.animation.has_animation("Dash"):
		if not player.animation.is_playing():
			return idle_state

	# Fall back to the normal timer end
	if dash_time <= 0:
		return idle_state

	return null

func process_physics(delta: float) -> State:
	player.move_and_slide()
	return null

func exit(new_state: State = null):
	player.velocity.x = 0
	return new_state
