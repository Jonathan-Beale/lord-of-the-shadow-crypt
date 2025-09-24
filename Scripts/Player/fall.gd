class_name PlayerFallState
extends PlayerState

#const jump_force: float = 75
#const air_speed: float = 20.0

func enter():
	#print("Fall State")
	#player.velocity.y = jump_force
	player.animation.play(jump_anim)

func exit(new_state: State = null):
	#print("Exit Fall State")
	#player.velocity.x = 0.0
	super(new_state)

func process_input(event: InputEvent) -> State:
	super(event)
	if not event.is_action_released(player.controls.right) or not event.is_action_released(player.controls.left):
		determine_sprite_flipped(event)
	if event.is_action_pressed(player.controls.punch):
		return punch_state
	if event.is_action_pressed(player.controls.kick):
		return kick_state
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
	player.velocity.x += move_dir * player.air_speed

func get_move_dir() -> float:
	var dir = Input.get_axis(player.controls.left, player.controls.right)
	#print("Direction: ",  dir)
	return dir
