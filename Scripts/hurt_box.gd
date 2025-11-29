class_name HurtBox
extends Area2D

@onready var dummy: Fighter = get_owner()
@onready var pain_state: State = $".."
@onready var state_machine: StateMachine = $"../.."

func _ready():
	collision_layer = 0
	collision_mask = 2
	self.area_entered.connect(on_area_entered)

func on_area_entered(hitbox: HitBox) -> void:
	if not hitbox:
		return

	var hb_owner = hitbox.get_owner()
	if hb_owner == dummy:
		return
	if hb_owner.is_in_group(dummy.team):
		return

	# --- Check for blocking ---
	if state_machine.current_state is PlayerBlockState:
		# Reduce damage and knockback while blocking
		var reduced_damage = hitbox.DAMAGE * 0.25  # 75% reduction
		var reduced_knockback = hitbox.KNOCKBACK * 0.25
		dummy.take_damage(reduced_damage, hitbox.DAMAGE_TYPE, hb_owner)
		# Optionally apply minor knockback manually
		dummy.velocity += (dummy.global_position - hitbox.global_position).normalized() * reduced_knockback
		return  # Don't enter Pain state

	# --- Normal damage flow ---
	state_machine.change_state(pain_state)
	hitbox.trigger_hit(dummy, pain_state)
