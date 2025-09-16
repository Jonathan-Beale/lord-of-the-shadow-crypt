class_name PlayerPunchState
extends PlayerState

var has_attacked: bool

func enter():
	has_attacked = false
	print("Punch State")
	player.animation.play(punch_anim)
	attacking = true
#	sets has attacked = true when animation ends
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)

func process_input(event: InputEvent) -> State:
	if event is InputEventJoypadMotion and abs(event.axis_value) < DEADZONE:
		return null
	super(event)
	if has_attacked and (event.is_action_pressed(left_key) or event.is_action_pressed(right_key)):
		determine_sprite_flipped(event)
		return walk_state
	if has_attacked and event.is_action_pressed(jump_key):
		return jump_state

	return null

func process_frame(delta: float):
	super(delta)
	if has_attacked: return idle_state
	
func exit(new_state: State = null):
	attacking = false
	return new_state
