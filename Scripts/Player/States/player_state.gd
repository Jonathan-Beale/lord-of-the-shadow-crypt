class_name PlayerState
extends State

@onready var player: Player = get_owner()
#@onready var player: Player = get_tree().get_first_node_in_group("Player")
signal facing_change(sprite_flipped)
const DEADZONE := 0.15

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 9.8)

var idle_anim: String = "Idle"
var walk_anim: String = "Walk"
var jump_anim: String = "Jump"
var fall_anim: String = "Fall"
var punch_anim: String = "Punch"
var kick_anim: String = "Kick"
var pain_anim: String = "Pain"
var crouch_anim: String = "Crouch"
var attacking: bool = false
var pained: bool = false

#@export_group("States")
@onready var idle_state:  PlayerState = (
	get_node_or_null(^"Idle") 
		if get_node_or_null(^"Idle") 
		else get_owner().get_node(^"StateMachine").get_node(^"Idle")
)
@onready var crouch_state:  PlayerState = (
	get_node_or_null(^"Crouch") 
		if get_node_or_null(^"Crouch") 
		else get_owner().get_node(^"StateMachine").get_node(^"Crouch")
)
@onready var pain_state: PlayerState = (
	get_node_or_null(^"Pain") 
		if get_node_or_null(^"Pain") 
		else get_owner().get_node(^"StateMachine").get_node(^"Pain")
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
@onready var punch_state: PlayerState = (
	get_node_or_null(^"Punch") 
		if get_node_or_null(^"Punch") 
		else get_owner().get_node(^"StateMachine").get_node(^"Punch")
)

@onready var kick_state: PlayerState = (
	get_node_or_null(^"Kick") 
		if get_node_or_null(^"Kick") 
		else get_owner().get_node(^"StateMachine").get_node(^"Kick")
)

var sprite_flipped: bool = false

func determine_sprite_flipped(_event: InputEvent) -> void:
	var current_state = sprite_flipped
	if player.velocity.x < 0:
		player.state_machine.scale.x = 1
		sprite_flipped = false
		player.sprite.position.x = -40
	elif player.velocity.x > 0:
		player.state_machine.scale.x = -1
		sprite_flipped = true
		player.sprite.position.x = 10
	player.sprite.flip_h = sprite_flipped
	#if current_state != sprite_flipped:

func process_physics(delta: float) -> State:
	#print("processing p2 physics")
	super(delta)
	player.velocity.y += gravity * delta


	var dir := Input.get_axis(player.controls.left, player.controls.right)

	# pick target horizontal speed (per second)
	var ground_speed := player.move_speed
	var air_speed := player.air_speed
	var target_speed := (ground_speed * dir) if player.is_on_floor() else (air_speed * dir)
	if (attacking and player.is_on_floor()) or pained:
		target_speed = 0.0

	# accelerate horizontally toward target (units: px/s^2)
	const ACCEL := 2000.0
	#if not attacking or not player.is_on_floor():?
	player.velocity.x = move_toward(player.velocity.x, target_speed, ACCEL * delta)

	# hard cap to max speed
	player.velocity.x = clamp(player.velocity.x, -player.max_speed, player.max_speed)

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

func process_input(event: InputEvent) -> State:
	if event is InputEventJoypadMotion and abs(event.axis_value) < DEADZONE:
		return null
		
	if not event.is_action_released(player.controls.left) or not event.is_action_released(player.controls.right):
		if not attacking:
			determine_sprite_flipped(event)
	return null

func get_move_dir() -> float:
	var dir = Input.get_axis(player.controls.left, player.controls.right)
	#print("Direction: ",  dir)
	return dir

func exit(new_state: State = null):
	super()
	if new_state:
		new_state.sprite_flipped = sprite_flipped
