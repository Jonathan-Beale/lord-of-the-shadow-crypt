class_name PlayerIdleState
extends PlayerState

func enter():
	print("Idle State")
	player.animation.play(idle_anim)

func exit(new_state: State = null):
	print("Exit Idle State")
	super(new_state)

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key):
		determine_sprite_flipped(event.as_text())
		return walk_state
	if event.is_action_pressed(jump_key):
		return jump_state

	return null
