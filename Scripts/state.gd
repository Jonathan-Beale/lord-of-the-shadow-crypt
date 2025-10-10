class_name State
extends Node

var label: String = "State"

func init():
	pass
	
func exit(new_state: State = null):
	pass

func enter():
	pass

func process_frame(delta: float) -> State:
	return null

func process_input(event: InputEvent) -> State:
	return null

func process_physics(delta: float) -> State:
	return null
