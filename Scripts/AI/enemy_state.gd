class_name EnemyState
extends State

@onready var enemy: Enemy = get_owner()
@onready var camera: Camera = get_tree().get_first_node_in_group("playerCam")
#@onready var player: Player = get_tree().get_first_node_in_group("Player")

const DEADZONE := 0.15

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 9.8)

var idle_anim: String = "Idle"
var walk_anim: String = "Walk"
var jump_anim: String = "Jump"
var fall_anim: String = "Fall"
var punch_anim: String = "Punch"
var kick_anim: String = "Kick"
var pain_anim: String = "Pain"
var death_anim: String = "Death"
var attacking: bool = false

#@export_group("States")
@onready var idle_state:  EnemyState = (
	get_node_or_null(^"Idle") 
		if get_node_or_null(^"Idle") 
		else get_owner().get_node(^"StateMachine").get_node(^"Idle")
)
@onready var walk_state:  EnemyState = (
	get_node_or_null(^"Walk") 
		if get_node_or_null(^"Walk") 
		else get_owner().get_node(^"StateMachine").get_node(^"Walk")
)
#@onready var jump_state:  EnemyState = (
	#get_node_or_null(^"Jump") 
		#if get_node_or_null(^"Jump") 
		#else get_owner().get_node(^"StateMachine").get_node(^"Jump")
#)
@onready var fall_state: EnemyState = (
	get_node_or_null(^"Fall") 
		if get_node_or_null(^"Fall") 
		else get_owner().get_node(^"StateMachine").get_node(^"Fall")
)
#@onready var punch_state: EnemyState = (
	#get_node_or_null(^"Punch") 
		#if get_node_or_null(^"Punch") 
		#else get_owner().get_node(^"StateMachine").get_node(^"Punch")
#)
#
#@onready var kick_state: EnemyState = (
	#get_node_or_null(^"Kick") 
		#if get_node_or_null(^"Kick") 
		#else get_owner().get_node(^"StateMachine").get_node(^"Kick")
#)

var sprite_flipped: bool = false

func can_attack() -> bool:
	return enemy.is_on_floor()

func can_transition() -> bool:
	# Default: states can transition freely
	return true

func determine_sprite_flipped(_event: InputEvent) -> void:
	if enemy.velocity.x > 0:
		enemy.state_machine.scale.x = 1
		sprite_flipped = false
	elif enemy.velocity.x < 0:
		enemy.state_machine.scale.x = -1
		sprite_flipped = true
	enemy.sprite.flip_h = sprite_flipped

func process_physics(delta: float) -> State:
	#print("processing p2 physics")
	super(delta)
	enemy.velocity.y += gravity * delta


	#var dir := Input.get_axis(enemy.controls.left, enemy.controls.right)
	var dir: float = 0.0

	# pick target horizontal speed (per second)
	var ground_speed := enemy.move_speed
	var air_speed := enemy.air_speed
	var target_speed := (ground_speed * dir) if enemy.is_on_floor() else (air_speed * dir)
	if attacking and enemy.is_on_floor():
		target_speed = 0.0

	# accelerate horizontally toward target (units: px/s^2)
	const ACCEL := 2000.0
	#if not attacking or not enemy.is_on_floor():?
	enemy.velocity.x = move_toward(enemy.velocity.x, target_speed, ACCEL * delta)

	# hard cap to max speed
	enemy.velocity.x = clamp(enemy.velocity.x, -enemy.max_speed, enemy.max_speed)

	# --- edge clamp (predict next step) ---
	var min_x := -180.0
	var max_x :=  180.0
	var next_x := enemy.global_position.x + enemy.velocity.x * delta

	if next_x < min_x:
		# trim velocity so we land exactly on the edge this frame
		enemy.velocity.x = max(0.0, (min_x - enemy.global_position.x) / delta)
	elif next_x > max_x:
		enemy.velocity.x = min(0.0, (max_x - enemy.global_position.x) / delta)

	enemy.move_and_slide()
	return null

func get_move_dir() -> float:
	var dir = Input.get_axis(enemy.controls.left, enemy.controls.right)
	#print("Direction: ",  dir)
	return dir

func exit(new_state: State = null):
	super()
	if new_state:
		new_state.sprite_flipped = sprite_flipped
