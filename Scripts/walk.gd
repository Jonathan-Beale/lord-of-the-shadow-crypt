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
	if event.is_action_pressed(movement_key): determine_sprite_flipped(event.as_text())
	if event.is_action_pressed(jump_key):
		return jump_state
	#else: return idle_state
	# if event.is_action_pressed(right_key): determine_sprite_flipped(event.as_text())
	return null

func process_physics(delta: float) -> State:
	var move := get_move_dir()
	#if stopping:
		#return idle_state
	#if move == 0.0: stopping = true
	#else: stopping = false
	if move == 0.0:
		return idle_state
	# do_move(move)
	super(delta)
	return null


func do_move(move_dir: float) -> void:
	if abs(player.velocity.x) < MAX_SPEED:
		player.velocity.x += move_dir * SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	#print("Direction: ",  dir)
	return dir

func exit(new_state: State = null):
	player.velocity.x = 0.0
	super(new_state)
