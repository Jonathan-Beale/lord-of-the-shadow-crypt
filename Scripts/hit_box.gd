class_name HitBox
extends Area2D

@onready var collision_shape: CollisionShape2D = $"CollisionShape2D"
var DAMAGE = 10

func _ready() -> void:
	collision_layer = 2
	collision_mask = 0
