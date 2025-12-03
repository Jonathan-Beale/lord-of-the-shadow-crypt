class_name PlayerSlashState
extends PlayerAttackState

func enter():
	super()

	player.animation.play(slash_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	player.play_light_attack_sound()
	attacking = false

func _ready():
	hitbox.DAMAGE = 90
