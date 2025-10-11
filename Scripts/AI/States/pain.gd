class_name EnemyPainState
extends EnemyState

var has_pained: bool

var knockback: float = 10
var knockback_vector: Vector2 = Vector2.ZERO

var stun_duration: float = 0.3  # how long enemy is stunned after hit
var stun_timer: float = 0.0

@onready var hurt_box: HurtBox = $"HurtBox"

func enter():
	has_pained = false
	enemy.animation.play(pain_anim)
	enemy.animation.animation_finished.connect(func(_anim): has_pained = true)

func process_physics(delta: float) -> State:
	# During stun, don't let them move normally
	if stun_timer < stun_duration:
		stun_timer += delta
		apply_knockback() # can still get pushed
		return null # stay in pain state until stun wears off

	apply_knockback()
	return super(delta)
	
func can_transition() -> bool:
	# Lock transitions during hit stun
	return has_pained and stun_timer >= stun_duration

func process_frame(delta: float):
	super(delta)
	if has_pained and stun_timer >= stun_duration:
		return idle_state
	
func add_juice() -> void:
	camera.set_zoom_str(1.015)
	camera.set_shake_str(Vector2(4,5))
	
func exit(new_state: State = null):
	enemy.velocity = Vector2.ZERO
	return new_state

func apply_knockback():
	knockback_vector.y = 0
	knockback_vector = knockback_vector.normalized()
	var push_mod = knockback_vector.x * knockback
	enemy.velocity.x -= push_mod
	enemy.move_and_slide()
