class_name PlayerIdleState
extends PlayerState

func enter():
	player.animation.play(idle_anim)

func exit():
	super()

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key):
		determine_sprite_flipped(event.as_text())
		return walk_state

	return null
