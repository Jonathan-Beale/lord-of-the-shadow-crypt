class_name DecisionAgent
extends Node2D

# -------- AI BEHAVIOR TUNING --------
@export var aggressiveness = 0.55     
@export var defensiveness = 0.10       
@export var wandering = 0.30         
@export var waiting = 0.15             
@export var randomness = 0.10         

# -------- ACTION MODIFIERS --------
@export var ATTACK_DISTANCE = 120.0
@export var ENGAGE_DISTANCE = 900.0
@export var ACTION_INTERVAL = 0.40
@export var ATTACK_COOLDOWN_FRAMES = 10
@export var JUMP_FREQUENCY = 0.002     


@export var enable_debug = false


var enemy = null
var state_machine = null
var rng = RandomNumberGenerator.new()

var in_attack_cooldown = false
var attack_cooldown_timer = 0.0
var time_since_action = 0.0


func _ready():
	enemy = get_parent()

	if enemy.has_node("StateMachine"):
		state_machine = enemy.get_node("StateMachine")

	rng.randomize()
	time_since_action = 0.0


func _process(delta):
	enemy.ai_input["jump"] = false
	enemy.ai_input["attack"] = false
	enemy.ai_input["kick"] = false

	var player = _get_closest_player()
	if player == null:
		enemy.ai_input["move_dir"] = 0
		return


	if in_attack_cooldown:
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0:
			in_attack_cooldown = false
		else:
			enemy.ai_input["move_dir"] = 0
			return


	if rng.randf() < JUMP_FREQUENCY * delta:
		var jump_state = _get_state("Jump")
		if jump_state != null:
			enemy.ai_input["jump"] = true
			state_machine.change_state(jump_state)
			return


	time_since_action += delta
	if time_since_action >= ACTION_INTERVAL:
		time_since_action = 0
		_decide(player)


func _decide(player):
	if player == null:
		return

	var dx = player.global_position.x - enemy.global_position.x
	var dist_abs = abs(dx)

	var roll = rng.randf()
	var mode = "aggressive"

	if roll < defensiveness:
		mode = "defensive"
	elif roll < defensiveness + wandering:
		mode = "wander"
	elif roll < defensiveness + wandering + waiting:
		mode = "wait"

	# ---- AGGRESSIVE MODE ----
	if mode == "aggressive":
		# Attack if close enough
		if dist_abs <= ATTACK_DISTANCE:
			if rng.randf() < aggressiveness:
				enemy.ai_input["move_dir"] = 0

				if rng.randf() < 0.6:
					var s = _get_state("Punch")
					if s != null:
						state_machine.change_state(s)
				else:
					var s2 = _get_state("Kick")
					if s2 != null:
						state_machine.change_state(s2)

				_start_attack_cooldown()
				return


		enemy.ai_input["move_dir"] = sign(dx)
		return

	# ---- DEFENSIVE MODE ----
	if mode == "defensive":
		enemy.ai_input["move_dir"] = -sign(dx)
		return

	# ---- WANDERING MODE ----
	if mode == "wander":
		enemy.ai_input["move_dir"] = rng.randf_range(-1, 1)
		return

	# ---- WAIT MODE ----
	if mode == "wait":
		enemy.ai_input["move_dir"] = 0
		return


func _start_attack_cooldown():
	in_attack_cooldown = true
	attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES / 60.0


func _get_state(name):
	if state_machine != null and state_machine.has_node(name):
		return state_machine.get_node(name)
	return null


func _get_closest_player():
	var players = get_tree().get_nodes_in_group("Player")
	var closest = null
	var min_dist = INF

	for p in players:
		if p != null and is_instance_valid(p):
			var dist = abs(p.global_position.x - enemy.global_position.x)
			if dist < min_dist:
				min_dist = dist
				closest = p

	return closest
