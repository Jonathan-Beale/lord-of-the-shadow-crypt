class_name PlayerHurtBox
extends HurtBox

@onready var player: Player = get_owner()

#func _ready() -> void:

func on_area_entered(hitbox: HitBox = null) -> void:
	if hitbox == null: return
	super(hitbox)
	#player.take_damage(hitbox.DAMAGE)
	# print(dummy.current_health)
