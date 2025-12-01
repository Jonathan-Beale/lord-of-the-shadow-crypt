extends CanvasLayer

signal resume_game
signal return_to_menu
@onready var resume_btn = $ResumeButton
@onready var quit_btn = $QuitButton

var is_paused := false

func _ready():
	visible = false
	
	print("THIS IS THE BRHJGHBJSFHJADFGHASJDFGHAJSDAS" , resume_btn)
	if resume_btn:
		print("RESSUUMMMMEEE")
		resume_btn.pressed.connect(_resume)
	if quit_btn:
		quit_btn.pressed.connect(_quit)

func toggle_pause():
	is_paused = true
	get_tree().paused = true
	visible = true

#func _on_ResumeButton_pressed():
	#toggle_pause()
	#emit_signal("resume_game")

#func _on_MainMenuButton_pressed():
	#get_tree().paused = false
	#emit_signal("return_to_menu")

func _resume():
	print("RESSUUMMMMEEE")
	visible = false
	get_tree().paused = false

func _quit():
	print("QUIIIIT")
	get_tree().paused = false
	var new_scene = load("res://Scenes/main_menu.tscn")
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
