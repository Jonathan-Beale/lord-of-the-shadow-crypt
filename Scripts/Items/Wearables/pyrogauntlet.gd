extends Wearable

var bonus_dmg
var dmg_mod
var speed_mod

func _ready():
#	5% bonus fire damage
	dmg_mod = user.DamageMod.new(user, 0.05, "fire")
	dmg_mod.add(user)
	
#	5 dps fire damage for 3 seconds
	bonus_dmg = user.BonusDamage.new(user, 5.0, "fire", true, 3.0)
	bonus_dmg.add(user)
	
#	Non-stacking 50% move speed buff from dealing fire damage
	speed_mod = user.SpeedMod.new(user, "boost", 0.15, user.SpeedStat.ALL)
	
	user.dot_tick.connect(_on_dot)
	user.dealt_damage.connect(_on_damage)
	
#	Bonus knockback (additive)
	user.knockback_mod += 1.0
	pass

func unequip():
	dmg_mod.remove()
	dmg_mod.delete()
	bonus_dmg.remove()
	bonus_dmg.delete()
	speed_mod.remove()
	speed_mod.delete()
	user.knockback_mod -= 1.0

func _on_damage(type: String, damage: float, target: Dummy, attacker: Fighter):
	if attacker != user: return
	if type == "fire":
		print(type)
		speed_mod.add(attacker)
		speed_mod.refresh()

func _on_dot(type: String, damage: float, target: Dummy, source: Fighter):
	if source != user: return
	if type == "fire":
		speed_mod.add(source)
		speed_mod.refresh()
