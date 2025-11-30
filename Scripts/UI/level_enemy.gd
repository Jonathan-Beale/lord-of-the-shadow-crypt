extends Node2D

var pause_menu
var game_mode = "PvP"
const PlayerScene := preload("res://Scenes/final_player.tscn")
const EnemyScene := preload("res://Scenes/enemy.tscn")
@onready var FightUI = $FightUI
var player_actions = []
signal round_over(move_log)
var enemy = EnemyScene.instantiate()

func set_up(players: int = 1):
	for i in range(players):
		var player = PlayerScene.instantiate()
		player.position = Vector2(-100, 50)
		add_child(player)
		player.state_machine.changing_state.connect(_record_move)
		player.dying.connect(_on_player_died)

	#var enemy = EnemyScene.instantiate()
	enemy.position = Vector2(50, 50)
	add_child(enemy)
	if enemy.has_signal("dying"):
		enemy.dying.connect(_on_enemy_died)
	if enemy.has_node("StateMachine"):
		enemy.state_machine.changing_state.connect(_record_move)

	FightUI.position = Vector2(-5, 18)
	FightUI._add_bars_coop(get_tree().get_nodes_in_group("Player"))
	FightUI.start_countdown()

func _record_move(state, global_pos, player):
	player_actions.append({
		"player": player,
		"state": state,
		"pos": global_pos
	})

func _on_player_died():
	finish(false)

func _on_enemy_died():
	enemy.animation.play("Death")
	finish(true)

func finish(player_won: bool = true):
	enemy.animation.play("Death")
	emit_signal("round_over", player_actions)
	var enemy_manager = get_tree().root.get_node_or_null("EnemyManager")
	if enemy_manager == null:
		for child in get_tree().root.get_children():
			if child.name == "EnemyManager":
				enemy_manager = child
				break

	if enemy_manager:
		if player_won:
			enemy.animation.play("Death")
			await get_tree().create_timer(1.0).timeout
			enemy_manager.return_from_battle()
		else:
			enemy.animation.play("Death")
			enemy_manager.pending_battle_enemy_id = -1
			await get_tree().create_timer(1.0).timeout
			enemy_manager.return_from_battle()
	else:
		enemy.animation.play("Death")
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file("res://assetsOW/ScenesOW/sakura_lvl.tscn")

func _ready():
	var packed = load("res://pause_menu.tscn")
	pause_menu = packed.instantiate()
	add_child(pause_menu)
	
	# Connect the menu’s signals
	pause_menu.resume_game.connect(_on_resume_game)
	pause_menu.return_to_menu.connect(_on_return_to_menu)
	set_up()
	
func _input(event):
	if event.is_action_pressed("ui_pause"):
		pause_menu.toggle_pause()

func _on_resume_game():
	# Optional: do anything special when resuming
	pass

func _on_return_to_menu():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
