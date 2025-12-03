extends ColorRect

@onready var versus_btn = $Versus
@onready var enemy_btn = $Enemy 
@onready var boss_btn = $Boss
@onready var click_sound = $ClickSound 
var background_color: Color = Color("#190609")

signal versus_match(players: int)
signal dungeon(players: int)
signal final_boss(players: int)

const MAIN_MENU_SCENE := "res://Scenes/main_menu.tscn"
const PVP_SCENE_PATH := "res://Scenes/level_pvp.tscn"
const ENEMY_SCENE_PATH := "res://assetsOW/ScenesOW/sakura_lvl.tscn"
const BOSS_SCENE_PATH := "res://Scenes/level_final_boss.tscn"

func _ready():
	size = get_viewport().get_visible_rect().size
	get_viewport().size_changed.connect(_on_viewport_resized)
	color = background_color
	
	versus_btn.pressed.connect(_on_versus_pressed)
	if enemy_btn:
		enemy_btn.pressed.connect(_on_enemy_pressed)
	if boss_btn:
		boss_btn.pressed.connect(_on_boss_pressed)

	# Connect to player death signal if player exists
	var player = get_tree().get_first_node_in_group("Player")
	if player and player.has_signal("dying"):
		player.dying.connect(Callable(self, "_on_player_died"))

func _on_viewport_resized():
	size = get_viewport().get_visible_rect().size


func _on_versus_pressed():
	_play_click_sound()
	emit_signal("versus_match", 2)
	print("Versus button pressed (PvP mode)")
	_load_scene(PVP_SCENE_PATH)

func _on_enemy_pressed():
	_play_click_sound()
	print("Enemy button pressed (Enemy mode)")
	_load_scene(ENEMY_SCENE_PATH)

func _on_boss_pressed():
	_play_click_sound()
	emit_signal("final_boss", 3)
	print("Boss button pressed (PVE mode)")
	_load_scene(BOSS_SCENE_PATH)


func _play_click_sound():
	if click_sound:
		click_sound.play()

func _load_scene(scene_path: String):
	var new_scene = load(scene_path)
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)


func _on_player_died():
	print("Player died! Returning to main menu...")
	_load_scene(MAIN_MENU_SCENE)
