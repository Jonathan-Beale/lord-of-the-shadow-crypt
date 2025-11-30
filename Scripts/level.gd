extends Node2D

var pause_menu
var game_mode = "PvP"
const PlayerScene := preload("res://Scenes/final_player.tscn")
@onready var FightUI = $FightUI


var player_actions = []

signal round_over(move_log)

func set_up(players: int = 2):
	for i in range(players):
		var player = load("res://Scenes/final_player.tscn").instantiate()
		player.position = Vector2(-120 * i, 50)
		add_child(player)
		player.state_machine.changing_state.connect(_record_move)
		player.dying.connect(finish)
	
	var player_agents: Array = get_tree().get_nodes_in_group("Player")
	FightUI.position = Vector2(-5, 18)
	FightUI._add_bars_pvp(player_agents)
	FightUI.start_countdown()

func _record_move(state, global_pos, player):
	player_actions.append({
		"player": player,
		"state": state,
		"pos": global_pos
	})

func finish():
	emit_signal("round_over", player_actions)

func _ready():
	var packed = load("res://pause_menu.tscn")
	pause_menu = packed.instantiate()
	add_child(pause_menu)
	
	# Connect the menu’s signals
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.return_to_menu.connect(_on_return_to_menu)
	

	
	var players: Array = get_tree().get_nodes_in_group("Player")
	print(position)
	set_up()
	
func _input(event):
	if event.is_action_pressed("ui_pause"):
		pause_menu.toggle_pause()

func _on_resume_game():
	# Optional: do anything special when resuming
	pass

func _on_return_to_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
