extends ColorRect

@onready var versus_btn = $Versus
@onready var enemy_btn = $Enemy 
@onready var boss_btn = $Boss
var background_color: Color = Color("#190609")

signal versus_match(players: int)
signal dungeon(players: int)
signal final_boss(players: int)

const PVP_SCENE_PATH := "res://Scenes/level_pvp.tscn"
const ENEMY_SCENE_PATH := "res://assetsOW/ScenesOW/sakura_lvl.tscn"
const BOSS_SCENE_PATH := "res://Scenes/level_final_boss.tscn"

func _ready():
	size = get_viewport().get_visible_rect().size
	
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	color = background_color
	
	versus_btn.pressed.connect(_versus)
	if enemy_btn:
		enemy_btn.pressed.connect(_enemy)
	if boss_btn:
		boss_btn.pressed.connect(_finalBoss)

func _on_viewport_resized():
	size = get_viewport().get_visible_rect().size

func _versus():
	emit_signal("versus_match", 2)
	print("Versus button pressed (PvP mode)")
	_load_scene(PVP_SCENE_PATH)
	
func _finalBoss():
	emit_signal("final_boss", 3)
	print("Boss button pressed (PVE mode)")
	_load_scene(BOSS_SCENE_PATH)


func _enemy():
	print("Enemy button pressed (Enemy mode)")
	_load_scene(ENEMY_SCENE_PATH)

func _dungeon():
	emit_signal("dungeon", 1)
	print("Entering the dungeon (not yet implemented)")


func _load_scene(scene_path: String):
	var new_scene = load(scene_path)
	if new_scene:
		get_tree().change_scene_to_packed(new_scene)
