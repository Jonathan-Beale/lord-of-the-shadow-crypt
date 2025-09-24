class_name HitBox
extends Area2D

@onready var collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var user: Fighter = get_owner()

var DAMAGE = 10
var KNOCKBACK = 10

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

func trigger_hit(target: Fighter):
	user.deal_damage(self, target)
	#target.take_damage(DAMAGE, "physical")
	#player.add_dot(10, 5)
