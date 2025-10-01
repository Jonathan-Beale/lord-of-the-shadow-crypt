extends Node2D

var game_mode = "PvP"
const PlayerScene := preload("res://Scenes/player.tscn")
@onready var FightUI = $FightUI

func set_up(players: int = 2):
	for i in range(players):
		var player = load("res://Scenes/player.tscn").instantiate()
		player.position = Vector2(100 * i, 20)
		add_child(player)
	
	var player_agents: Array = get_tree().get_nodes_in_group("Player")
	FightUI.position = Vector2(0, 20)
	FightUI._add_bars_pvp(player_agents)

func _ready():
	var players: Array = get_tree().get_nodes_in_group("Player")
	print(position)
	set_up()
