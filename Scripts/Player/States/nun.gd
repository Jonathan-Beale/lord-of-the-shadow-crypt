class_name PlayerNunState
extends PlayerAttackState

func enter():
	super()
	player.animation.play(nun1_anim)
	player.play_light_attack_sound()
	player.animation.animation_finished.connect(func(_anim): has_attacked = true)
	
func add_juice() -> void:
	camera.set_zoom_str(1.019)
	camera.set_shake_str(Vector2(4,5))
	# maybe change to play only when hurt animation plays

func _ready():
	hitbox.DAMAGE = 100
	hitbox.KNOCKBACK = -5
	current_state = "nun1"
	combo_chain = [PlayerKickState, PlayerSlashState, PlayerBlockState, PlayerDashState, PlayerHeavyState, PlayerPunchState, PlayerNun2State]
	cancel_window_start = 0.15   # when cancel window opens
	cancel_window_end = 0.5     # when cancel window closes
