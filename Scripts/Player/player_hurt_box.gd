class_name PlayerHurtBox
extends HurtBox

@onready var player: Player = get_owner()
@onready var pain_state: PlayerPainState = $".."
@onready var StateMachine: StateMachine = $"../.."
var hitting_area: HitBox


func on_area_entered(hitbox: HitBox = null) -> void:
	if hitbox == null: return
	var hb_owner = hitbox.get_owner()
	if hb_owner == player:
		return
	if hb_owner.is_in_group(player.team):
		return
	hitting_area = hitbox
	super(hitbox)
	StateMachine.change_state(pain_state)
	hitbox.trigger_hit(player)
	#player.take_damage(hitbox.DAMAGE)
	print(player.current_health)
