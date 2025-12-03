extends CanvasLayer

signal resume_game
signal return_to_menu

@onready var resume_btn = $ResumeButton
@onready var quit_btn = $QuitButton
@onready var click_sound = $ClickSound  

var is_paused := false

func _ready():
	visible = false

	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

func toggle_pause():
	is_paused = true
	get_tree().paused = true
	visible = true

func _on_resume_pressed():
	_play_click_sound()
	visible = false
	get_tree().paused = false
	emit_signal("resume_game")

func _on_quit_pressed():
	_play_click_sound()
	get_tree().paused = false
	emit_signal("return_to_menu")
	var new_scene = load("res://Scenes/main_menu.tscn")

func _play_click_sound():
	if click_sound:
		click_sound.play()
