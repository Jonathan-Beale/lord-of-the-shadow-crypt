extends Wearable

var reduction_timer: float = 0.0

# Heals the player for %missing-health
# reduced of taken fire damage recently

func equip():
	owner.max_health += 100
	owner.current_health += 100

func _ready():
	user.damage_taken.connect(_damage_taken)

func unequip():
	owner.max_health -= 100
	if owner.current_health > owner.max_health:
		owner.max_health = owner.current_health

func _damage_taken(type: String, amount: float, target: Dummy, source: Fighter):
#	Taking fire damage resets the timer to 3 seconds
	if type == "fire":
		reduction_timer = 3.0

func _process(delta: float) -> void:
#	recieve reduced healing if recently burned
	if reduction_timer > 0:
		reduction_timer -= delta
		heal_user(true, delta)
	else:
		reduction_timer = 0
		heal_user(false, delta)

func heal_user(reduced_healing: bool, delta: float):
	var missing_health = user.max_health - user.current_health
	if missing_health <= 0: return
	var heal
	if reduced_healing: # Heal for 1% missing health
		heal = (missing_health * 0.01) * delta
	else: # Heal for 2% + 10 missing health
		heal = (missing_health * 0.02 + 10) * delta
	if heal > missing_health:
		user.current_health = user.max_health
	else:
		user.current_health += heal
