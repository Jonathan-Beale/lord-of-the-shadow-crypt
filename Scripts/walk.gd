class_name PlayerWalkState
extends PlayerState

const SPEED: float = 5.0
#const MAX_SPEED: float = 180.0
var stopping = false

func enter():
	super()
	print("Walk State")
	player.animation.play(walk_anim)

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(jump_key):
		return jump_state
	if event.is_action_pressed(punch_key):
		return punch_state
	if event.is_action_released(right_key) and event.is_action_released(left_key):
		return idle_state
	return null

func process_physics(delta: float) -> State:
	super(delta)
	if player.velocity.x == 0:
		return idle_state
	return null


func do_move(move_dir: float) -> void:
	if abs(player.velocity.x) < MAX_SPEED:
		player.velocity.x += move_dir * SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	return dir

func exit(new_state: State = null):
	if new_state == idle_state:
		player.velocity.x = 0.0
	super(new_state)
