class_name StateMachine
extends Node

var current_state: State

@onready var starting_state: State = $Idle

func init(): change_state(starting_state)
signal changing_state(new_state, global_pos, entity)

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

func _dump_state(s: State) -> void:
	var sc = s.get_script()
	print({
		"node": s,
		"name": s.name,
		"get_class": s.get_class(),
		"script": sc,
		"script_path": sc and sc.resource_path,
		"is_State": s is State,
		# Replace IdleState/WalkState with your actual classes
		"is_IdleState": (s is PlayerIdleState),
		"is_WalkState": (s is PlayerWalkState),
	})

func change_state(new_state: State):
	if not new_state: return null
	#if new_state == starting_state: print("P2 Entering idle state")
	if current_state: current_state.exit(new_state)
	current_state = new_state
	if current_state:
		current_state.enter()
		if not (new_state is PlayerPainState):
			#print("not pain state")
			emit_signal("changing_state", current_state.name, self.global_position, get_owner())
			#_dump_state(current_state)
			#if current_state is State:
				#print("Entering a new state")
		
