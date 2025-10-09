class_name PlayerPunchState
extends PlayerAttackState

func enter():
	super()
	player.animation.play(punch_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	attacking = false
	
func add_juice() -> void:
	camera.set_zoom_str(1.015)
	camera.set_shake_str(Vector2(4,5))

func _ready():
	hitbox.DAMAGE = 100
