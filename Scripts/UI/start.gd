extends Control

const FightScene := preload("res://Scenes/level.tscn")
const MainMenu  := preload("res://Scenes/main_menu.tscn")

var fight_scene: Node
var main_menu: Node

var fight_log = []

func _ready() -> void:
	main_menu = MainMenu.instantiate()
	add_child(main_menu)

	# Godot 4 connection (two equivalent styles):
	# main_menu.versus_match.connect(_start_versus)
	main_menu.connect("versus_match", Callable(self, "_start_versus"))

func _start_versus(players: int) -> void:
	# remove menu
	if is_instance_valid(main_menu):
		main_menu.queue_free()
		main_menu = null

	# create and add fight scene
	fight_scene = FightScene.instantiate()
	add_child(fight_scene)
	fight_scene.round_over.connect(_record_moves)
	# pass game mode/players to the scene if it has an API for it
	# fight_scene.enter_fight("PvP", players)

func _record_moves(move_log):
	fight_log.append(move_log)
	print(move_log)
