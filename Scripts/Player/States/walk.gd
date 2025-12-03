class_name PlayerWalkState
extends PlayerState

const SPEED: float = 5.0
#const max_speed: float = 180.0
var stopping = false

const STEP_INTERVAL := 0.25
var step_timer := 0.0

func enter():
	super()
	#print("Walk State")
	player.animation.play(walk_anim)
	step_timer = 0.0

func process_input(event: InputEvent) -> State:
	super(event)
	if event.is_action_pressed(player.controls.up):
		return jump_state
	if event.is_action_pressed(player.controls.punch):
		return punch_state
	if event.is_action_pressed(player.controls.kick):
		return kick_state
	if event.is_action_released(player.controls.right) and event.is_action_released(player.controls.left):
		return idle_state
	if event.is_action_pressed(player.controls.slash):
		return slash_state
	if event.is_action_pressed(player.controls.block):
		return block_state
	if event.is_action_pressed(player.controls.dash) and not attacking and not pained:
		return dash_state
	if event.is_action_pressed(player.controls.heavy):
		return heavy_state
	if event.is_action_pressed(player.controls.nun):
		return nun_state
	return null

func process_physics(delta: float) -> State:
	super(delta)
	if player.velocity.x == 0:
		
		return idle_state
	
	# Footsteps while moving and on the ground
	if player.is_on_floor() and abs(player.velocity.x) > 0.1:
		step_timer -= delta
		if step_timer <= 0.0:
			player.play_stone_footstep_sound()
			step_timer = STEP_INTERVAL
	
	return null


func do_move(move_dir: float) -> void:
	if abs(player.velocity.x) < player.max_speed:
		player.velocity.x += move_dir * SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(player.controls.left, player.controls.right)
	return dir

func exit(new_state: State = null):
	if new_state == idle_state:
		player.velocity.x = 0.0
	super(new_state)
