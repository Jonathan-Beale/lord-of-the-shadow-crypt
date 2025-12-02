class_name HitBox
extends Area2D

@onready var collision_shape: CollisionShape2D = $"CollisionShape2D"
@onready var user: Fighter = get_owner()

var DAMAGE = 10
var KNOCKBACK = 10
var DAMAGE_TYPE = "physical"

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0

func trigger_hit(target: Fighter, pain: State):
	if user and user.has_method("play_impact_sound"):
		user.play_impact_sound()
	
	 # Deal normal damage
	user.deal_damage(target, DAMAGE_TYPE, DAMAGE)

	# Only apply knockback if this is actually a pain state that defines the properties
	if pain is PlayerPainState:
		pain.knockback = KNOCKBACK + target.knockback_mod
		pain.knockback_vector = (target.global_position - user.global_position).normalized()
