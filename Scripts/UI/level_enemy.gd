extends Node2D

var game_mode = "PvP"
const PlayerScene := preload("res://Scenes/final_player.tscn")
const EnemyScene := preload("res://Scenes/enemy.tscn")  
@onready var FightUI = $FightUI

var player_actions = []

signal round_over(move_log)

func set_up(players: int = 1):
	
	for i in range(players):
		var player = PlayerScene.instantiate()
		player.position = Vector2(-100, 50)
		add_child(player)
		player.state_machine.changing_state.connect(_record_move)
		player.dying.connect(finish)
	
	var enemy = EnemyScene.instantiate()
	enemy.position = Vector2(100, 50)  
	add_child(enemy)

	if enemy.has_signal("dying"):
		enemy.dying.connect(finish)
	if enemy.has_node("StateMachine"):
		enemy.state_machine.changing_state.connect(_record_move)
	
	
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
	set_up()
