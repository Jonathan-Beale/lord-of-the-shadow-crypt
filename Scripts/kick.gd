class_name PlayerKickState
extends PlayerState

func enter():
	print("Kick State")
	player.animation.play(kick_anim)

func exit(new_state: State = null):
	print("Exit Kick State")
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

	return null
