extends Node
"""
const PauseMenuScene = preload("res://pause_menu.tscn")
var pause_menu: CanvasLayer

func _ready():
	add_to_group("PauseManager")
	pause_menu = PauseMenuScene.instantiate()
	get_tree().root.add_child(pause_menu)
	pause_menu.visible = false
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	print("PauseMenu instantiated:", pause_menu)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	if pause_menu == null:
		return

	if get_tree().paused:
		resume_game()
	else:
		pause_game()
		
func pause_game():
	print("PAUSE triggered")
	pause_menu.visible = true
	pause_menu.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	
func resume_game():
	print("UNPAUSE triggered")
	pause_menu.visible = false
	get_tree().paused = false
	
#func _unhandled_key_input(event):
	#if event.is_action_pressed("ui_cancel"):
		#get_tree().call_group("PauseManager", "resume_game")
"""
