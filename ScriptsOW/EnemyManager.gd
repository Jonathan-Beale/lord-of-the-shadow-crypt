extends Node

# List of defeated enemies' IDs
var defeated_enemies: Array = []

# Reference to the UI label
@export var counter_label: NodePath
@onready var label: Label = null

func _ready():
	# Get the label reference
	if not counter_label.is_empty():
		label = get_node(counter_label)
	else:
		# Try to find it automatically
		label = get_tree().root.find_child("EnemyCounter", true, false)
	
	# Update the display initially
	update_counter_display()

# Register an enemy as defeated
func defeat_enemy(enemy_id: int) -> void:
	if enemy_id in defeated_enemies:
		return
	defeated_enemies.append(enemy_id)
	update_counter_display()

# Update the UI label
func update_counter_display() -> void:
	if label != null:
		label.text = "Enemies Defeated: " + str(defeated_enemies.size())
