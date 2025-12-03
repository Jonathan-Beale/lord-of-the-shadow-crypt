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
	hitbox.DAMAGE = 30
	combo_chain = [PlayerKickState, PlayerSlashState, PlayerBlockState, PlayerDashState]
	cancel_window_start = 0.15   # when cancel window opens
	cancel_window_end = 0.50     # when cancel window closes
