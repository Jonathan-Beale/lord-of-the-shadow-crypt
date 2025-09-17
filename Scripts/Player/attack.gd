class_name PlayerAttackState
extends PlayerState

var has_attacked: bool
@onready var hitbox: HitBox = $HitBox

func enter():
	has_attacked = false
	#if sprite_flipped: hitbox.scale.x = -1
	#else: hitbox.scale.x = 1
	attacking = true
	print("Attack State")

func process_input(event: InputEvent) -> State:
	if event is InputEventJoypadMotion and abs(event.axis_value) < DEADZONE:
		return null
	super(event)
	if has_attacked and (event.is_action_pressed(player.controls.left) or event.is_action_pressed(player.controls.right)):
		determine_sprite_flipped(event)
		return walk_state
	if has_attacked and event.is_action_pressed(player.controls.up):
		return jump_state

	return null

func process_frame(delta: float):
	super(delta)
	if has_attacked: return idle_state
	
func exit(new_state: State = null):
	print("Exit Attack State")
	attacking = false
	hitbox.collision_shape.disabled = true
	return new_state
