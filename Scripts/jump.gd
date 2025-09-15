class_name PlayerJumpState
extends PlayerState

#const JUMP_FORCE: float = 300
#const AIR_SPEED: float = 20.0

func enter():
	print("Jump State")
	player.velocity.y = -JUMP_FORCE
	player.animation.play(jump_anim)

func exit(new_state: State = null):
	print("Exit Jump State")
	#player.velocity.x = 0.0
	super(new_state)

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key):
		determine_sprite_flipped(event.as_text())
	if event.is_action_released(jump_key):
		player.velocity.y = 0.0
	return null

func process_physics(delta: float) -> State:
	if player.velocity.y > 0:
		return fall_state
	#var move := get_move_dir()
	#do_move(move)
	return super(delta)
	
func do_move(move_dir: float) -> void:
	player.velocity.x += move_dir * AIR_SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	#print("Direction: ",  dir)
	return dir
