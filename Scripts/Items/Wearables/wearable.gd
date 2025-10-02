class_name Wearable
extends Node2D

@onready var user: Fighter = get_owner()
var item_name = "Wearable Item"
var item_description = "An item that effects your stats and does not give a unique attack animation"
var burns = []


func _ready():
	self.add_to_group("Wearable")
	equip()

func _process(delta: float) -> void:
#	test item makes you heal 10 + 2% missing health per second
	#if user.current_health < user.max_health:
		#var missing_health = user.max_health - user.current_health
		#user.current_health += (10 + 0.02 * missing_health) * delta
	pass

func equip():
#	user.max_health += 1000
	pass

func unequip():
#	user.max_health -= 1000
	pass

# Loadable from json
# % health burn
# on damage type
# burn type
# burn amount
# max stacks