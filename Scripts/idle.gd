class_name PlayerIdleState
extends PlayerState

func enter():
	print("Idle State")
	player.animation.play(idle_anim)

func exit(new_state: State = null):
	print("Exit Idle State")
	super(new_state)

func process_input(event: InputEvent) -> State:
	if event is InputEventJoypadMotion and abs(event.axis_value) < DEADZONE:
		return null
	super(event)
	if event.is_action_pressed(left_key) or event.is_action_pressed(right_key):
		determine_sprite_flipped(event)
		return walk_state
	if event.is_action_pressed(jump_key):
		return jump_state
	if event.is_action_pressed(punch_key):
		return punch_state
	if event.is_action_pressed(kick_key):
		return kick_state

	return null
