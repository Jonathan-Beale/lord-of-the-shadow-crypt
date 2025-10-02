class_name PlayerPainState
extends PlayerState

var has_pained: bool

var knockback: float = 10
var knockback_vector: Vector2 = Vector2.ZERO

@onready var hurt_box: PlayerHurtBox = $"HurtBox"

func enter():
	has_pained = false
	pained = true
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
	#print("Exit Pain State")
	player.velocity = Vector2.ZERO
	pained = false
	return new_state

func apply_knockback():
	knockback_vector.y = 0
	knockback_vector = knockback_vector.normalized()
	var push_mod = knockback_vector.x * knockback
	#print(push_mod)
	player.velocity.x -= push_mod
	player.move_and_slide()
	#print(hurt_box.hitting_area.DAMAGE)
