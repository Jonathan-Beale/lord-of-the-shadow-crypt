class_name PlayerWalkState
extends PlayerState

const SPEED: float = 4.0

func enter():
	super()
	print("Walk State")
	player.animation.play(walk_anim)

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(movement_key): determine_sprite_flipped(event.as_text())
	else: return idle_state
	# if event.is_action_pressed(right_key): determine_sprite_flipped(event.as_text())
	return null

func process_physics(delta: float) -> State:
	var move := get_move_dir()
	do_move(move)
	super(delta)
	# print(get_move_dir())
	print("Velocity: ", player.velocity)
	if abs(player.velocity.x) < 0.1:
		player.velocity.x = 0.0
		return idle_state
	if is_zero_approx(move):
		return idle_state
	return null


func do_move(move_dir: float) -> void:
	player.velocity.x += move_dir * SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	print(dir)
	return dir

func exit():
	player.velocity.x = 0.0
	super()
