class_name HurtBox
extends Area2D

@onready var dummy: Dummy = get_owner()
@onready var pain_state: State = $".."
@onready var state_machine: StateMachine = $"../.."

func _ready():
	collision_layer = 0
	collision_mask = 2
	self.area_entered.connect(on_area_entered)

func on_area_entered(hitbox: HitBox = null) -> void:
	if not hitbox: return
	var hb_owner = hitbox.get_owner()
	if hb_owner == dummy: return
	if hb_owner.is_in_group(dummy.team): return
	state_machine.change_state(pain_state)
	hitbox.trigger_hit(dummy, pain_state)
	
	#print("OOOF!")
