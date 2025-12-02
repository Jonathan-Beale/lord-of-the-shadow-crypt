class_name PlayerNun3State
extends PlayerAttackState

func enter():
	super()
	player.animation.play(nun3_anim)
	player.play_heavy_attack_sound()
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	
func add_juice() -> void:
	camera.set_zoom_str(1.019)
	camera.set_shake_str(Vector2(4,5))
	# maybe change to play only when hurt animation plays

func _ready():
	hitbox.DAMAGE = 100
	hitbox.KNOCKBACK = -5
	combo_chain = []
	cancel_window_start = 0.15   # when cancel window opens
	cancel_window_end = 0.5     # when cancel window closes
