class_name StateMachine
extends Node

var current_state: State

@export var starting_state: State

func init(): change_state(starting_state)

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

func change_state(new_state: State):
	print("Changing states")
	if not new_state: return null
	if current_state: current_state.exit()
	current_state = new_state
	if current_state:
		current_state.enter()
