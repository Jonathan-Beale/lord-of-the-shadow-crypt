extends ColorRect

@onready var versus_btn = $Versus
@onready var enemy_btn = $Enemy 
var background_color: Color = Color("#2c2c64")

signal versus_match(players: int)
signal dungeon(players: int)

const PVP_SCENE_PATH := "res://Scenes/level_pvp.tscn"
const ENEMY_SCENE_PATH := "res://assetsOW/ScenesOW/sakura_lvl.tscn"

func _ready():
	size = get_viewport().get_visible_rect().size
	
	get_viewport().size_changed.connect(_on_viewport_resized)
	
	color = background_color
	
	versus_btn.pressed.connect(_versus)
	if enemy_btn:
		enemy_btn.pressed.connect(_enemy)

func _on_viewport_resized():
	size = get_viewport().get_visible_rect().size

func _versus():
	emit_signal("versus_match", 2)
	print("Versus button pressed (PvP mode)")
	_load_scene(PVP_SCENE_PATH)


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
