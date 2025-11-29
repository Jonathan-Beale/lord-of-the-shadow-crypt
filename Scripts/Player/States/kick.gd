class_name PlayerKickState
extends PlayerAttackState

func enter():
	super()
	player.animation.play(kick_anim)
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	
func add_juice() -> void:
	camera.set_zoom_str(1.019)
	camera.set_shake_str(Vector2(4,5))
	# maybe change to play only when hurt animation plays

func _ready():
	hitbox.DAMAGE = 300
	hitbox.KNOCKBACK = 30
	combo_chain = [PlayerSlashState, PlayerBlockState]
	cancel_window_start = 0.2   # when cancel window opens
	cancel_window_end = 0.45     # when cancel window closes
