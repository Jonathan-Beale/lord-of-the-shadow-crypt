extends Wearable

var speed_mod
var charged: bool = true
var cooldown: float = 6.0
var remaining_cooldown: float = 6.0
var burst_damage: float = 20.0

func _ready():		
#	Non-stacking 50% move speed buff from dealing fire damage
	speed_mod = user.SpeedMod.new(user, "boost", 0.15, user.SpeedStat.ALL)
	
	user.dot_tick.connect(_on_dot)
	user.dealt_damage.connect(_on_damage)
	
	pass

func unequip():
	speed_mod.remove()
	speed_mod.delete()

func _process(delta: float) -> void:
	if charged: return
	remaining_cooldown -= delta
	if remaining_cooldown <= 0.0:
		charged = true

func _on_damage(type: String, damage: float, target: Dummy, attacker: Fighter):
	if attacker != user: return
	if charged:
		charged = false
		remaining_cooldown = cooldown
		speed_mod.add(attacker)
		speed_mod.refresh()
		attacker.deal_damage(target, "electric", burst_damage)

func _on_dot(type: String, damage: float, target: Dummy, attacker: Fighter):
	if attacker != user: return
	#if charged:
		#speed_mod.add(attacker)
		#speed_mod.refresh()
		#attacker.deal_damage(target, "electric", burst_damage)
		#charged = false
