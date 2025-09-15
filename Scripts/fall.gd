class_name PlayerFallState
extends PlayerState

#const JUMP_FORCE: float = 75
#const AIR_SPEED: float = 20.0

func enter():
	print("Fall State")
	#player.velocity.y = JUMP_FORCE
	player.animation.play(jump_anim)

func exit(new_state: State = null):
	print("Exit Fall State")
	#player.velocity.x = 0.0
	super(new_state)

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key):
		determine_sprite_flipped(event)
	return null

func process_physics(delta: float) -> State:
	if player.is_on_floor():
		if get_move_dir() != 0.0:
			return walk_state
		else:
			return idle_state
	var move := get_move_dir()
	#do_move(move)
	player.velocity.y += gravity * delta
	player.move_and_slide()
	return null
	
func do_move(move_dir: float) -> void:
	player.velocity.x += move_dir * AIR_SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	#print("Direction: ",  dir)
	return dir
