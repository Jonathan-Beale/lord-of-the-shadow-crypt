class_name PlayerSlashState
extends PlayerAttackState

func enter():
	super()
	print("Animation node:", player.animation)
	print("Has slash animation:", player.animation.has_animation(slash_anim))
	if(camera == null):
		print("NOOOOO")
	player.animation.play(slash_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	attacking = false

func _ready():
	hitbox.DAMAGE = 100
