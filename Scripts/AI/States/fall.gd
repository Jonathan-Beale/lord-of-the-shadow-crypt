class_name EnemyFallState
extends EnemyState

#const jump_force: float = 75
#const air_speed: float = 20.0

func enter():
	#print("Fall State")
	#player.velocity.y = jump_force
	enemy.animation.play(fall_anim)

func exit(new_state: State = null):
	#print("Exit Fall State")
	#player.velocity.x = 0.0
	super(new_state)

func process_physics(delta: float) -> State:
	if enemy.is_on_floor():
		if get_move_dir() != 0.0:
			return walk_state
		else:
			return idle_state
	var move := get_move_dir()
	#do_move(move)
	enemy.velocity.y += gravity * delta
	enemy.move_and_slide()
	return null
	
func do_move(move_dir: float) -> void:
	enemy.velocity.x += move_dir * enemy.air_speed

func get_move_dir() -> float:
	var dir = Input.get_axis(enemy.controls.left, enemy.controls.right)
	#print("Direction: ",  dir)
	return dir
