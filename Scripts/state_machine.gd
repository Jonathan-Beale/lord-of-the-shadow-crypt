class_name StateMachine
extends Node

var current_state: State
@onready var starting_state: State = $Idle

signal changing_state(new_state, global_pos, entity)

func init():
	change_state(starting_state)

# --- Regular state updates ---
func process_frame(delta: float) -> State:
	if current_state:
		var new_state: State = current_state.process_frame(delta)
		change_state(new_state)
	return null

func process_input(event: InputEvent) -> State:
	if current_state:
		var new_state: State = current_state.process_input(event)
		change_state(new_state)
	return null

func process_physics(delta: float) -> State:
	if current_state:
		var new_state: State = current_state.process_physics(delta)
		change_state(new_state)
	return null

# --- Debug helper ---
func _dump_state(s: State) -> void:
	var sc = s.get_script()
	print({
		"node": s,
		"name": s.name,
		"get_class": s.get_class(),
		"script": sc,
		"script_path": sc and sc.resource_path,
		"is_State": s is State,
		"is_IdleState": (s is PlayerIdleState),
		"is_WalkState": (s is PlayerWalkState),
	})

# --- Standard state change ---
func change_state(new_state: State):
	if not new_state:
		return null
	if current_state and not current_state.can_transition():
		return null
	if current_state:
		current_state.exit(new_state)
	current_state = new_state
	if current_state:
		current_state.enter()
		if not (new_state is PlayerPainState):
			emit_signal("changing_state", current_state.name, self.global_position, get_owner())

# --- New: Try to change state only if move is unlocked ---
func try_change_state(state_name: String, move_name: String = ""):
	var owner_player = get_owner() as Player
	if move_name != "" and owner_player and not owner_player.can_use_move(move_name):
		print(move_name + " is locked!")
		# Optional: play "move locked" sound here
		return

	var state = _get_state_by_name(state_name)
	if state:
		change_state(state)

func _get_state_by_name(name: String) -> State:
	if has_node(name):
		return get_node(name)
	return null
