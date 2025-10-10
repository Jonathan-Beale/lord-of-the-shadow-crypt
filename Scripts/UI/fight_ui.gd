# HUD.gd
extends Control

@onready var background: ColorRect = $Background
@onready var fight_label = $Label

const BAR_W := 150.0
const BAR_H := 15.0
const BAR_PADDING := 6.0

var mode := "PvP"  # or "Co-op"

func _ready() -> void:
	set_as_top_level(true)
	# Keep it correct on resize
	get_viewport().connect("size_changed", Callable(self, "_on_viewport_resized"))
	_on_viewport_resized()
	
	var vp = get_viewport_rect().size
	background.size = Vector2(vp.x, max(30.0, vp.y * 0.05))

	# Find players
	var players: Array = get_tree().get_nodes_in_group("Player")
	if players.is_empty():
		return
	
	
	if(players.size()==1):	
		mode = "Coop"
	
	if mode == "PvP":
		_add_bars_pvp(players)
	elif mode == "Coop":
		_add_bars_coop(players)
		
	start_countdown()
		
func _on_viewport_resized() -> void:
	var size: Vector2 = get_viewport().get_visible_rect().size
	# Re-affirm top-left and bar layout on resize
	#global_position = Vector2(-size.x / 2, -size.y / 2)
	
func start_countdown() -> void:
	# Start counting down from 3 to 1
	print("starting countdown")
	fight_label.add_theme_font_size_override("font_size", 64)
	for i in range(3, 0, -1):
		fight_label.text = str(i)
		await get_tree().create_timer(1.0).timeout
	
	# Optional: display "Go!" at the end
	fight_label.text = "Fight!"
	await get_tree().create_timer(0.5).timeout
	fight_label.text = ""


func _add_bars_coop(players: Array) -> void:
	# Stack all bars on the left inside the background
	var x := 10.0
	var y := 10.0
	for i in players.size():
		print("ADDING HEALTHBARSSSSS")
		var bar := preload("res://Scenes/health_bar.tscn").instantiate() as HealthBar
		background.add_child(bar)            # local to background
		bar.position = Vector2(x, y)
		bar.set_player(players[i])
		y += BAR_H + BAR_PADDING
	# Set up enemy health bar


	var enemyBar := preload("res://Scenes/enemy_health_bar.tscn").instantiate()
	var enemies = get_tree().get_nodes_in_group("Enemy")
	if enemies.size() > 0:
		var enemy = enemies[0]
		enemyBar.set_enemy(enemy)       
	enemyBar.set_as_top_level(true)
	background.add_child(enemyBar)
	enemyBar.position = Vector2(10, 10)

func _add_bars_pvp(players: Array) -> void:
	print("Adding bars")
	# Split by team name (expects player.team == "Team 1" / "Team 2")
	var left_team: Array = []
	var right_team: Array = []
	for p in players:
		var t: String = (p.team if "team" in p else "Team 1")
		if t == "Team 2":
			print("Adding to right team")
			right_team.append(p)
		else:
			print("Adding to left team")
			left_team.append(p)

	var left_x := 10.0
	var right_x: float = max(10.0, (background.size.x / 2) - BAR_W * 2 - 10.0)
	var y_left := 10.0
	var y_right := 10.0

	for p in left_team:
		var bar := preload("res://Scenes/health_bar.tscn").instantiate() as HealthBar
		background.add_child(bar)
		bar.position = Vector2(left_x, y_left)
		bar.set_player(p)
		y_left += BAR_H + BAR_PADDING
		print("Team 1 bar added")

	for p in right_team:
		var bar := preload("res://Scenes/health_bar.tscn").instantiate() as HealthBar
		background.add_child(bar)
		bar.position = Vector2(right_x, y_right)
		bar.set_player(p)
		y_right += BAR_H + BAR_PADDING
		print("Team 2 bar added")
