class_name UnitEntity
extends CharacterBody2D

const START__HEALTH: float = 1000.0
var current_health: float = START__HEALTH
var max_health: float = START__HEALTH

func take_damage(amount: float, type: String = "physical"):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()  # Placeholder for death logic, e.g., play animation, notify game
