class_name EnemyPainState
extends EnemyState

var has_pained: bool

var knockback: float = 10
var knockback_vector: Vector2 = Vector2.ZERO

@onready var hurt_box: HurtBox = $"HurtBox"

func enter():
	has_pained = false
	enemy.animation.play(pain_anim)
	enemy.animation.animation_finished.connect(func(_anim): has_pained = true)

func process_physics(delta: float) -> State:
	apply_knockback()
	return super(delta)

func process_frame(delta: float):
	super(delta)
	if has_pained: return idle_state
	
func exit(new_state: State = null):
	enemy.velocity = Vector2.ZERO
	return new_state

func apply_knockback():
	knockback_vector.y = 0
	knockback_vector = knockback_vector.normalized()
	var push_mod = knockback_vector.x * knockback
	enemy.velocity.x -= push_mod
	enemy.move_and_slide()
