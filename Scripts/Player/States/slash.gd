class_name PlayerSlashState
extends PlayerAttackState

func enter():
	super()

	player.animation.play(slash_anim)
	player.play_heavy_attack_sound()
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	attacking = false

func _ready():
	hitbox.DAMAGE = 100
