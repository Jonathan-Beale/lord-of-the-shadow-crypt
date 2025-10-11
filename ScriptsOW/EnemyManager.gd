extends Node


var defeated_enemies: Array = []


@export var counter_label: NodePath
@onready var label: Label = null

func _ready():

	if not counter_label.is_empty():
		label = get_node(counter_label)
	else:

		label = get_tree().root.find_child("EnemyCounter", true, false)
	

	update_counter_display()


func defeat_enemy(enemy_id: int) -> void:
	if enemy_id in defeated_enemies:
		return
	defeated_enemies.append(enemy_id)
	update_counter_display()


func update_counter_display() -> void:
	if label != null:
		label.text = "Enemies Defeated: " + str(defeated_enemies.size())
