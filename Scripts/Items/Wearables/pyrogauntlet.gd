extends Wearable


func _ready():
#func equip():
	var dmg_mod = user.DamageMod.new(user, 5.0, "fire", true, 3.0)
	dmg_mod.add(user)
#	user.max_health += 1000
	pass

func unequip():
	pass
