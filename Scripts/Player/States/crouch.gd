class_name  CrouchState
extends PlayerState

func enter():
	player.animation.play(crouch_anim)
	pain_state.hurt_box.scale.y = 0.7
	pain_state.hurt_box.position.y = 15

func exit(new_state: State = null):
	super(new_state)
	pain_state.hurt_box.scale.y = 1
	pain_state.hurt_box.position.y = 0

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
	return null
