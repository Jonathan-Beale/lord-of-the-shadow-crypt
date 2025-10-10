class_name PlayerAttackState
extends PlayerState

var has_attacked: bool
@onready var hitbox: HitBox = $HitBox

# Combo + Cancel System
var attack_timer: float = 0.0
var cancel_window_start: float = 0.2
var cancel_window_end: float = 0.45
var attack_duration: float = 0.6
var can_cancel: bool = false

# Define what attacks this can chain into
var combo_chain: Array = []  # e.g. [PlayerAttack2, PlayerAttack3]
var next_attack_state: State = null

# Optional: input buffer
var input_buffer: StringName = ""
var buffer_timer: float = 0.0
const BUFFER_TIME := 0.15

func _ready():
	hitbox.collision_shape.disabled = true

func enter():
	has_attacked = false
	attacking = true
	attack_timer = 0.0
	can_cancel = false
	next_attack_state = null
	buffer_timer = 0.0
	hitbox.collision_shape.disabled = false
	player.animation.play("attack_light") # Or whichever animation
	print("Entered Attack State")

func process_input(event: InputEvent) -> State:
	super(event)

	# Store buffered attack input
	if event.is_pressed():
		for action_name in InputMap.get_actions():
			if Input.is_action_pressed(action_name):
				input_buffer = action_name
				buffer_timer = BUFFER_TIME
				break
		print(input_buffer)

	# Only allow cancel if inside the cancel window
	if can_cancel and input_buffer != "":
		# Example: light attack -> heavy attack
		var parent = get_parent()
		if input_buffer == "attack_2" and PlayerKickState in combo_chain: #ALLOW CONTROLLER SUPPORT
			return parent.get_node("Kick")
		if input_buffer == "attack_3" and PlayerSlashState in combo_chain:
			return parent.get_node("Slash")

	# Default transitions (after attack)
	if has_attacked:
		if event.is_action_pressed(player.controls.left) or event.is_action_pressed(player.controls.right):
			determine_sprite_flipped(event)
			return walk_state
		if event.is_action_pressed(player.controls.up):
			return jump_state

	return null

func process_frame(delta: float):
	super(delta)

	# Track timing for cancel windows
	attack_timer += delta

	if buffer_timer > 0:
		buffer_timer -= delta
	else:
		input_buffer = ""

	can_cancel = attack_timer >= cancel_window_start and attack_timer <= cancel_window_end

	# Attack ends after full duration
	if attack_timer >= attack_duration:
		has_attacked = true

	if has_attacked:
		if Input.is_action_pressed(player.controls.left) or Input.is_action_pressed(player.controls.right):
			return walk_state
		else:
			return idle_state

func exit(new_state: State = null):
	print("Exit Attack State")
	attacking = false
	hitbox.collision_shape.disabled = true
	return new_state
