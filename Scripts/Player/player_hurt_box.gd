class_name PlayerHurtBox
extends HurtBox

func on_area_entered(hitbox: HitBox = null) -> void:
	if hitbox == null: return
	super(hitbox)
	#player.take_damage(hitbox.DAMAGE)
	# print(dummy.current_health)
