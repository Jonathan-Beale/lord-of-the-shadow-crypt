extends Node2D

var game_mode = "PvP"
const PlayerScene := preload("res://Scenes/final_player.tscn")
@onready var FightUI = $FightUI

var player_actions = []

signal round_over(move_log)

func set_up(players: int = 2):
	for i in range(players):
		var player = load("res://Scenes/final_player.tscn").instantiate()
		player.position = Vector2(100 * i, 20)
		add_child(player)
		player.state_machine.changing_state.connect(_record_move)
		player.dying.connect(finish)
	
	var player_agents: Array = get_tree().get_nodes_in_group("Player")
	FightUI.position = Vector2(0, 20)
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
	var players: Array = get_tree().get_nodes_in_group("Player")
	print(position)
	set_up()
