class_name EnemyJumpState
extends EnemyState

const JUMP_SPEED = -350.0
const GRAVITY = 900.0
const MOVE_SPEED = 80.0
const EDGE_LEFT = -180.0
const EDGE_RIGHT = 180.0
const GROUND_LEVEL = 50.0  

var velocity = Vector2.ZERO
var has_jumped = false
var move_dir = 1.0

func enter():
	var enemy = get_owner()
	if enemy.animation:
		enemy.animation.play("Jump")

	velocity = enemy.velocity 
	if enemy.is_on_floor():
		velocity.y = JUMP_SPEED
		has_jumped = true
	else:
		has_jumped = true 

	var player = get_closest_player()
	if player != null:
		if player.global_position.x > enemy.global_position.x:
			move_dir = 1
		else:
			move_dir = -1
	else:
		move_dir = randf_range(-1.0, 1.0)

func process_frame(delta: float) -> State:
	var enemy = get_owner()
	
	
	if !enemy.is_on_floor():
		var attack = enemy.ai_input.get("attack", false)
		var kick = enemy.ai_input.get("kick", false)
		
		if attack:
			var punch_state = get_parent().get_node("Punch")
			if punch_state:
				return punch_state
		elif kick:
			var kick_state = get_parent().get_node("Kick")
			if kick_state:
				return kick_state
	
	return null

func process_physics(delta):
	var enemy = get_owner()
	velocity.y += GRAVITY * delta
	velocity.x = move_dir * MOVE_SPEED
	
	#if enemy.velocity.y > 0:
		#return fall_state

	enemy.velocity = velocity
	enemy.move_and_slide()
	
	##debug for not returning to ground 
	##print("Jump State - Y pos: ", enemy.global_position.y, " Y vel: ", enemy.velocity.y, " On floor: ", enemy.is_on_floor())

	if enemy.global_position.x < EDGE_LEFT:
		enemy.global_position.x = EDGE_LEFT
		move_dir = 1
	elif enemy.global_position.x > EDGE_RIGHT:
		enemy.global_position.x = EDGE_RIGHT
		move_dir = -1

	var player = get_closest_player()
	if player and enemy.sprite:
		if player.global_position.x < enemy.global_position.x:
			enemy.sprite.flip_h = true
		else:
			enemy.sprite.flip_h = false

	if enemy.is_on_floor():
		return get_parent().get_node("Idle")
	
	if enemy.is_on_floor() and has_jumped and velocity.y >= 0 and enemy.global_position.y >= GROUND_LEVEL - 2.0:
		enemy.global_position.y = GROUND_LEVEL
		velocity.y = 0
		enemy.velocity = velocity
		
		
		var idle_state = get_parent().get_node("Idle")
		if idle_state:
			return idle_state

	return null

func exit(new_state = null):
	pass

func get_closest_player():
	var enemy = get_owner()
	var closest = null
	var min_dist = 99999
	var players = get_tree().get_nodes_in_group("Player")
	for p in players:
		var d = abs(p.global_position.x - enemy.global_position.x)
		if d < min_dist:
			min_dist = d
			closest = p
	return closest
