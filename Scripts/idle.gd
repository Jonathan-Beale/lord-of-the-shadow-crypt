class_name PlayerIdleState
extends PlayerState
const DEADZONE := 0.15

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
	print(event)
	print(event.is_action_pressed(movement_key))
	if event.is_action_pressed(movement_key):
		determine_sprite_flipped(event)
		return walk_state
	if event.is_action_pressed(jump_key):
		return jump_state

	return null
