class_name PlayerHeavyState
extends PlayerAttackState

func enter():
	super()
	has_attacked = false
	
	player.animation.play(heavy_anim)
	player.animation.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished(anim_name: String):
	if anim_name == heavy_anim:
		has_attacked = true

func add_juice() -> void:
	camera.set_zoom_str(1.019)
	camera.set_shake_str(Vector2(4,5))

func _ready():
	hitbox.DAMAGE = 300
	hitbox.KNOCKBACK = -30
	combo_chain = [PlayerBlockState]
	cancel_window_start = 0.3
	cancel_window_end = 0.45
