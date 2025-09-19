class_name Item
extends Node2D

@onready var user: UnitEntity = get_owner()

func _process(delta: float) -> void:
#	test item makes you heal 10 + 2% missing health per second
	if user.current_health < user.max_health:
		var missing_health = user.max_health - user.current_health
		user.current_health += (10 + 0.02 * missing_health) * delta
