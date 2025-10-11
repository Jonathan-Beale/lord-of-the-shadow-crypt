class_name PlayerIdleState
extends PlayerState

func enter():
	#print("Idle State")
	player.animation.play(idle_anim)

func exit(new_state: State = null):
	#print("Exit Idle State")
	super(new_state)

func process_input(event: InputEvent) -> State:
	if event is InputEventJoypadMotion and abs(event.axis_value) < DEADZONE:
		return null
	super(event)
	if event.is_action_pressed(player.controls.left) or event.is_action_pressed(player.controls.right):
		determine_sprite_flipped(event)
		return walk_state
	if event.is_action_pressed(player.controls.up):
		return jump_state
	if event.is_action_pressed(player.controls.punch):
		return punch_state
	if event.is_action_pressed(player.controls.kick):
		return kick_state
	if event.is_action_pressed(player.controls.down):
		return crouch_state
	if event.is_action_pressed(player.controls.slash):
		return slash_state
	

	return null
