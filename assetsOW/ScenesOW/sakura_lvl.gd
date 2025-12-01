extends Node2D

var pause_menu

func _ready():
	var packed = load("res://pause_menu.tscn")
	pause_menu = packed.instantiate()
	add_child(pause_menu)
	
	# Connect the menu’s signals
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.return_to_menu.connect(_on_return_to_menu)

func _input(event):
	if event.is_action_pressed("ui_pause"):
		pause_menu.toggle_pause()

func _on_resume_game():
	# Optional: do anything special when resuming
	pass

func _on_return_to_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
