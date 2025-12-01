class_name DecisionAgent
extends Node2D

# -- ai traits --
@export var aggressiveness = 3.6      # higher -> prefers attacking
@export var defensiveness = 0.3       # higher -> retreats more
@export var wandering = 0.2           # higher -> wanders and doesnt engage
@export var waiting = 0.6             # higher -> slower decisions
@export var randomness = 0.2          # higher -> changes mind more often

# -- action modifiers -- 
@export var ATTACK_DISTANCE = 50.0
@export var ENGAGE_DISTANCE = 320.0
@export var ACTION_INTERVAL = 0.6
@export var ATTACK_COOLDOWN_FRAMES = 4  
@export var JUMP_FREQUENCY = 0.42  

# -- descision output debug stuff -- 
@export var enable_debug = false      

var enemy = null
var state_machine = null
var time_since_action = 0.0
var rng = RandomNumberGenerator.new()
var attack_cooldown_timer = 0.0
var in_attack_cooldown = false

func _ready():
	enemy = get_parent()

	if enemy.has_node("StateMachine"):
		state_machine = enemy.get_node("StateMachine")

	rng.randomize()
	time_since_action = 0.0
	
	if enable_debug:
		print("[DecisionAgent] Initialized for: ", enemy.name)

func _process(delta):

	# reset inputs
	enemy.ai_input["jump"] = false
	enemy.ai_input["attack"] = false
	enemy.ai_input["kick"] = false

	# find closest player
	var player = _get_closest_player()

	# handle attack animation cooldown
	# prevents it from attacking over itself
	if in_attack_cooldown:
		
		attack_cooldown_timer -= delta
		if attack_cooldown_timer <= 0.0:
			in_attack_cooldown = false
			_debug_print("Attack cooldown finished")
			
		else:
			
			# freeze movement while waiting for attack to finish
			enemy.ai_input["move_dir"] = 0.0
			return

	# random jumping to throw player off
	if rng.randf() < JUMP_FREQUENCY * delta:
		enemy.ai_input["jump"] = true
		var jump_node = _get_state("Jump")
		
		if jump_node != null and state_machine.current_state != jump_node:
			enemy.ai_input["move_dir"] = 0.0
			state_machine.change_state(jump_node)
			_debug_print("STATE: Jump (spontaneous)")
			return

	# adjust time in between each action
	time_since_action += delta
	if time_since_action < ACTION_INTERVAL * (1.0 + waiting * 0.5):
		if rng.randf() < randomness * delta * 2.0:
			_decide_next_action(player)
		return

	time_since_action = 0.0
	_decide_next_action(player)

# choosing action based off of mode profile
func _decide_next_action(player):
	var dx = player.global_position.x - enemy.global_position.x
	var dist_abs = abs(dx)

	var mode = "aggressive"

	# weighted logic based on personality
	# rng roll makes mode chosen based on importance in personality
	var roll = rng.randf()
	
	if roll < defensiveness:
		mode = "defensive"
	elif roll < defensiveness + wandering:
		mode = "wandering"
	else:
		mode = "aggressive"

	# debug printing 
	_debug_print("Mode: %s | Distance: %.1f | Direction: %s" % [mode, dist_abs, "left" if dx < 0 else "right"])

	# -- agressive mode --
	if mode == "aggressive" and dist_abs <= ATTACK_DISTANCE and rng.randf() < aggressiveness:
		enemy.ai_input["move_dir"] = 0.0

		# will randomly attack punch or kick
		if rng.randf() < 0.5:
			enemy.ai_input["attack"] = true
			var punch_node = _get_state("Punch")
			
			if punch_node != null:
				state_machine.change_state(punch_node)
				_start_attack_cooldown()
				_debug_print("STATE: Punch | Distance: %.1f" % dist_abs)
			return
			
		else:
			enemy.ai_input["kick"] = true
			var kick_node = _get_state("Kick")
			
			if kick_node != null:
				state_machine.change_state(kick_node)
				_start_attack_cooldown()
				_debug_print("STATE: Kick | Distance: %.1f" % dist_abs)
				
			return

	# -- defensive mode --
	elif mode == "defensive":
		enemy.ai_input["move_dir"] = -sign(dx)
		_debug_print("STATE: Walk (retreating) | move_dir: %.1f" % enemy.ai_input["move_dir"])
		
		if dist_abs > ENGAGE_DISTANCE * 1.2:
			enemy.ai_input["move_dir"] = 0.0
			_debug_print("STATE: Idle (far enough away)")

	# -- wandering mode --
	elif mode == "wandering":
		if rng.randf() < 0.5:
			enemy.ai_input["move_dir"] = rng.randf_range(-1.0, 1.0)
			_debug_print("STATE: Walk (wandering) | move_dir: %.1f" % enemy.ai_input["move_dir"])
			
		else:
			enemy.ai_input["move_dir"] = 0.0
			_debug_print("STATE: Idle (pausing)")

	# -- appraoching mode aka. generic  --
	else:
		enemy.ai_input["move_dir"] = sign(dx)
		_debug_print("STATE: Walk (approaching) | move_dir: %.1f" % enemy.ai_input["move_dir"])


# debug printing 
func _debug_print(message: String):
	if enable_debug:
		print("[%s] %s" % [enemy.name, message])


func _start_attack_cooldown():
	in_attack_cooldown = true
	attack_cooldown_timer = ATTACK_COOLDOWN_FRAMES / 60.0  

func _get_state(name):
	if state_machine != null and state_machine.has_node(name):
		return state_machine.get_node(name)
	return null

# finding location relative to player
func _get_closest_player():
	var players = get_tree().get_nodes_in_group("Player")
	var closest = null
	var min_dist = 99999
	for p in players:
		
		var dist = abs(p.global_position.x - enemy.global_position.x)
		
		if dist < min_dist:
			min_dist = dist
			closest = p
			
	return closest
