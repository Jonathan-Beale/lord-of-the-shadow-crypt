class_name PlayerKickState
extends PlayerAttackState

func enter():
	super()
	player.animation.play(kick_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)

func _ready():
	hitbox.DAMAGE = 400
	hitbox.KNOCKBACK = 40
