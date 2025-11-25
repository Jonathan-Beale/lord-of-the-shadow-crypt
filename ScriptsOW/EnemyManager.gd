extends Node

var defeated_enemies: Array = []
var pending_battle_enemy_id: int = -1
var player_return_position: Vector2 = Vector2.ZERO
var return_scene_path: String = ""

@export var counter_label: NodePath
@onready var label: Label = null

static var instance: Node = null

func _enter_tree():
	if instance == null:
		instance = self
		get_parent().remove_child(self)
		get_tree().root.add_child(self)
	else:
		queue_free()

func _ready():
	if not counter_label.is_empty():
		label = get_node(counter_label)
	else:
		label = get_tree().current_scene.find_child("EnemyCounter", true, false)

	if pending_battle_enemy_id != -1:
		defeat_enemy(pending_battle_enemy_id)
		pending_battle_enemy_id = -1
		await get_tree().process_frame
		var player = get_tree().get_first_node_in_group("player")
		if player and player_return_position != Vector2.ZERO:
			player.global_position = player_return_position

	update_counter_display()

func start_battle(enemy_id: int, player_pos: Vector2, battle_scene: String = "res://Scenes/level_enemy.tscn"):
	pending_battle_enemy_id = enemy_id
	player_return_position = player_pos
	return_scene_path = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(battle_scene)

func return_from_battle():
	if return_scene_path != "":
		get_tree().change_scene_to_file(return_scene_path)

func defeat_enemy(enemy_id: int) -> void:
	if enemy_id in defeated_enemies:
		return
	defeated_enemies.append(enemy_id)
	update_counter_display()

func update_counter_display() -> void:
	if label == null or not is_instance_valid(label):
		label = get_tree().current_scene.find_child("EnemyCounter", true, false)
	if label != null:
		global.total_defeated += 1
		label.text = " Enemies Defeated: " + str(global.total_defeated) + "\n WASD or Left Stick To Move\n I for Inventory" + "\n DESCEND INTO THE CRYPT \n AND DEFEAT THE SHADOW LORD"
