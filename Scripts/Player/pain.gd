class_name PlayerPainState
extends PlayerState

var has_pained: bool
@onready var hurt_box: PlayerHurtBox = $"HurtBox"

func enter():
	has_pained = false
	print("Pain State")
	player.animation.play(pain_anim)
	player.animation.animation_finished.connect(func(_anim): has_pained = true)

func process_input(event: InputEvent) -> State:
	if event is InputEventJoypadMotion and abs(event.axis_value) < DEADZONE:
		return null
	super(event)
	if has_pained and (event.is_action_pressed(player.controls.left) or event.is_action_pressed(player.controls.right)):
		determine_sprite_flipped(event)
		return walk_state
	if has_pained and event.is_action_pressed(player.controls.up):
		return jump_state

	return null

func process_physics(delta: float) -> State:
	apply_knockback()
	return super(delta)

func process_frame(delta: float):
	super(delta)
	if has_pained: return idle_state
	
func exit(new_state: State = null):
	print("Exit Pain State")
	player.velocity = Vector2.ZERO
	return new_state

func apply_knockback():
	var push_dir: Vector2 = hurt_box.hitting_area.collision_shape.global_position - self.global_position
	push_dir.y = 0
	push_dir = push_dir.normalized()
	var damage_force_multiplier = hurt_box.hitting_area.DAMAGE * hurt_box.hitting_area.DAMAGE
	print(damage_force_multiplier)
	var push_mod = push_dir.x * damage_force_multiplier
	print(push_mod)
	player.velocity.x -= push_mod
	#print(hurt_box.hitting_area.DAMAGE)
