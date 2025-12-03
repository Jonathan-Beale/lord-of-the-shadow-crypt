class_name EnemyAttackState
extends EnemyState

var has_attacked: bool
@onready var hitbox: HitBox = $HitBox

func enter():
	has_attacked = false
	attacking = true
	
func process_frame(delta: float):
	super(delta)
	if has_attacked: return idle_state
	
func exit(new_state: State = null):
	attacking = false
	hitbox.collision_shape.disabled = true
	return new_state
