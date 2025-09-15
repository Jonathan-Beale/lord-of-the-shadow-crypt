class_name PlayerState
extends State

@onready var player: Player = get_tree().get_first_node_in_group("Player")

const JUMP_FORCE: float = 450
const AIR_SPEED: float = 1020
const MOVE_SPEED: float = 820
const MAX_SPEED: float = 160

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 9.8)

var idle_anim: String = "Idle"
var walk_anim: String = "Walk"
var jump_anim: String = "Jump"
var fall_anim: String = "Fall"
var punch_anim: String = "Punch"
var kick_anim: String = "Kick"

#@export_group("States")
@onready var idle_state:  PlayerState = (
	get_node_or_null(^"Idle") 
		if get_node_or_null(^"Idle") 
		else get_owner().get_node(^"StateMachine").get_node(^"Idle")
)
@onready var walk_state:  PlayerState = (
	get_node_or_null(^"Walk") 
		if get_node_or_null(^"Walk") 
		else get_owner().get_node(^"StateMachine").get_node(^"Walk")
)
@onready var jump_state:  PlayerState = (
	get_node_or_null(^"Jump") 
		if get_node_or_null(^"Jump") 
		else get_owner().get_node(^"StateMachine").get_node(^"Jump")
)
@onready var fall_state: PlayerState = (
	get_node_or_null(^"Fall") 
		if get_node_or_null(^"Fall") 
		else get_owner().get_node(^"StateMachine").get_node(^"Fall")
)

#@onready var punch_state: PlayerState = get_owner().get_node(^"Punch")

var sprite_flipped: bool = false

var movement_key: String = "Movement"
var left_key: String = "ui_left"
var right_key: String = "ui_right"
var jump_key: String = "ui_up"
var punch_key: String = "attack_1"
var kick_key: String = "attack_2"

var left_actions: Array = [InputMap.action_get_events(left_key).map(func(action: InputEvent) -> String:
	return action.as_text().get_slice(" (", 0))[-1]]
var right_actions: Array = [InputMap.action_get_events(right_key).map(func(action: InputEvent) -> String:
	return action.as_text().get_slice(" (", 0))[-1]]


func determine_sprite_flipped(event_text: String) -> void:
	if left_actions.find(event_text) != -1: sprite_flipped = true
	if right_actions.find(event_text) != -1: sprite_flipped = false
	player.sprite.flip_h = sprite_flipped
	pass

func process_physics(delta: float) -> State:
	super(delta)
	player.velocity.y += gravity * delta


	var dir := Input.get_axis(left_key, right_key)

	# pick target horizontal speed (per second)
	var ground_speed := MOVE_SPEED
	var air_speed := AIR_SPEED
	var target_speed := (ground_speed * dir) if player.is_on_floor() else (air_speed * dir)

	# accelerate horizontally toward target (units: px/s^2)
	const ACCEL := 2000.0
	player.velocity.x = move_toward(player.velocity.x, target_speed, ACCEL * delta)

	# hard cap to max speed
	player.velocity.x = clamp(player.velocity.x, -MAX_SPEED, MAX_SPEED)

	# --- edge clamp (predict next step) ---
	var min_x := -180.0
	var max_x :=  180.0
	var next_x := player.global_position.x + player.velocity.x * delta

	if next_x < min_x:
		# trim velocity so we land exactly on the edge this frame
		player.velocity.x = max(0.0, (min_x - player.global_position.x) / delta)
	elif next_x > max_x:
		player.velocity.x = min(0.0, (max_x - player.global_position.x) / delta)

	player.move_and_slide()
	return null

func do_move(move_dir: float) -> void:
	print("Player POS: ", player.global_position)
	print("Player X: ", player.global_position.x)
	if player.global_position.x < -180.0 and move_dir < 0:
		player.velocity.x = 0.0
		return
	if player.global_position.x > 180.0 and move_dir > 0:
		player.velocity.x = 0.0
		return
	if player.is_on_floor():
		if abs(player.velocity.x) < MAX_SPEED:
			player.velocity.x += move_dir * MOVE_SPEED
	else:
		player.velocity.x += move_dir * AIR_SPEED

func get_move_dir() -> float:
	var dir = Input.get_axis(left_key, right_key)
	#print("Direction: ",  dir)
	return dir

func exit(new_state: State = null):
	super()
	if new_state:
		new_state.sprite_flipped = sprite_flipped
