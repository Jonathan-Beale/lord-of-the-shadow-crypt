extends Wearable

func equip():
	owner.max_health += 100
	owner.current_health += 100

func unequip():
	owner.max_health -= 100
	if owner.current_health > owner.max_health:
		owner.max_health = owner.current_health
