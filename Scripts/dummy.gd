class_name Dummy
extends CharacterBody2D
"""
A Class that has durability mods and takes/blocks damage
"""
# Health Stats
const START_HEALTH: float = 1000.0
var max_health: Stat = Stat.new(1000.0)
var current_health: float = max_health.base

# Grey Health Trackers
var grey_health: float = 0.0
var gh_timer: float = 0.0

# Grey Health Mods
var gh_damage_ratio: Stat = Stat.new(0.5) # ratio at which damage taken is converted to grey health
var gh_heal_ratio: Stat = Stat.new(0.5) # ratio at whih grey health is converted to health
var gh_recovery_rate: Stat = Stat.new(0.05) # rate at which grey health recovers
var gh_delay: Stat = Stat.new(3.0) # delay before grey health healing begins

var anti_heal: Stat = Stat.new(0.5)
var heal_power: Stat = Stat.new(0.5)

var update_needed: bool = false
var stat_mods: Array[Global.ModBase] = []
var dot_mods: Array[Global.ModBase] = []

# Shields
var shields = {
	"generic": [],
	"fire": [],
	"ice": [],
	"shadow": [],
	"electric": [],
	"physical": []
}

# Resistance Stats
var resists = {
	"fire": Stat.new(25.0),
	"ice": Stat.new(25.0),
	"shadow": Stat.new(25.0),
	"electric": Stat.new(25.0),
	"physical": Stat.new(50.0)
}

class Stat:
	var base: float
	var bonus: float = 0.0
	var total: float

	func _init(b: float = 0.0):
		base = b
		total = b
	
	func clac_total():
		total = base + bonus
	
	func set_bonus(b: float):
		bonus = b
		clac_total()
	
	func add_bonus(b: float):
		bonus += b
		clac_total()


signal damage_blocked(type: String, damage: float, target: Dummy, attacker: Fighter)
signal recovering()
signal dot_applied(type: String, stacks: int, dps: float, duration_left: float)
signal dot_tick(type: String, damage: float, target: Dummy, source: Fighter)
signal dot_expired(type: String)
signal damage_taken(type: String, amount: float, target: Dummy, source: Fighter)
signal healing_done(amount: float, source: Node2D)
signal dying()


func modify_stat(stat, amount, type, operator):
	if stat == Global.StatTypes.MAX_HEALTH:
		max_health.add_bonus(amount)
	elif stat == Global.StatTypes.GH_DAMAGE_RATIO:
		gh_damage_ratio.add_bonus(amount)
	elif stat == Global.StatTypes.GH_HEAL_RATIO:
		gh_heal_ratio.add_bonus(amount)
	elif stat == Global.StatTypes.GH_RECOVERY_RATE:
		gh_recovery_rate.add_bonus(amount)
	elif stat == Global.StatTypes.GH_DELAY:
		gh_delay.add_bonus(amount)
	elif stat == Global.StatTypes.RESIST:
		if not type: return
		resists[type].add_bonus(amount)
	elif stat == Global.StatTypes.ANTI_HEAL:
		anti_heal.add_bonus(amount)
	elif stat == Global.StatTypes.HEAL_POWER:
		heal_power.add_bonus(amount)

func add_shield(n_shield):
	var duration = n_shield.duration
	var type = n_shield.type
	if duration == 0.0:
		shields[type].append(n_shield)
		return
	for i in range(shields[type].size()):
		var c_shield = shields[type][i]
		if c_shield.duration == 0.0:
			shields[type].insert(i, n_shield)
			return
		if c_shield.duration_remaining > duration:
			shields[type].insert(i, n_shield)
			return


func add_mod(mod: Global.ModBase):
	update_needed = true
	if mod.duration == 0.0:
		stat_mods.append(mod)
	else:
		for i in range(stat_mods.size()):
			if stat_mods[i].duration == 0.0:
				stat_mods.insert(i, mod)
				return
			if stat_mods[i].duration_remaining > mod.duration:
				stat_mods.insert(i, mod)
				return
		stat_mods.append(mod)

func _update_mods(delta: float):
	update_needed = false
	for mod in stat_mods:
		if mod.duration > 0.0:
			update_needed = true
			mod.duration_remaining -= delta
			if mod.duration_remaining <= 0:
				mod.remove()

# --- DoT system --------------------------------------------------------------
# One manager list, updated once per frame. No Timer nodes per effect.
# amount is DPS (damage per second) by default.

func _process(delta: float) -> void:
	_update_grey_health(delta)
	_update_dots(delta)
	_update_shields(delta)
	if update_needed:	_update_mods(delta)

func _update_shields(delta: float):
	for key in shields.keys():
		for i in range(shields[key].size() - 1, -1, -1):
			var shield = shields[key][i]
			if shield.duration == 0.0: break
			shield.duration_remaining -= delta
			if shield.duration_remaining <= 0.0:
				shield.remove()

func _update_grey_health(delta: float):
	if gh_timer > 0.0:
		gh_timer -= delta
		if gh_timer <= 0.0:
			gh_timer = 0.0
			emit_signal("recovering")
		return
	if grey_health <= 0.0:
		return
	var gh_used = max_health.total * gh_recovery_rate.total * delta
	if gh_used > grey_health: gh_used = grey_health
	grey_health -= gh_used
	var healing = gh_used * gh_heal_ratio.total
	#print("Recovering ", healing, " health")
	heal(healing)

func heal(amount: float, source = self):
	var final_healing = amount * (1 - anti_heal.total) * (1 + heal_power.total)
	emit_signal("healing_done", amount, source)
	current_health += final_healing

func _update_dots(delta: float) -> void:
	#print("Updating dot")
	for i in range(dot_mods.size() - 1, -1, -1):
		var mod = dot_mods[i]
		if mod.duration > 0.0:
			mod.duration_remaining -= delta
			var base_damage = mod.amount * delta
			var agg: float = mod.source.calc_damage_mod(base_damage, mod.type)
			var dmg = agg + base_damage
			take_damage(dmg, mod.type, mod.source)
			mod.source.emit_signal("dot_tick", mod.type, dmg, self, mod.source)

			if mod.duration_remaining <= 0:
				mod.remove()
				mod.source.emit_signal("dot_expired", mod.type)

# --- Damage / death ----------------------------------------------------------
func take_damage(amount: float, type: String = "physical", source: Fighter = null) -> float:
	# var r := float(resists.get(type, 100.0))
	var r: float = resists[type].total

	# Apply source armor pen
	r -= r * source.percent_pen[type]
	r -= source.flat_pen[type]
	r = max(r, 0.0) # avoid negatives
	var resist_quotient: float = 100.0 / (100.0 + r)
	var post_resist_dmg = amount * resist_quotient
	var final_dmg = post_resist_dmg

	# Shield damage reduction
	while shields[type].size() > 0 and final_dmg > 0:
		var shield = shields[type][0]
		if shield.amount <= final_dmg:
			final_dmg -= shield.amount
			shields[type].pop_front()
			shield.remove()
		else:
			shield.amount -= final_dmg
			final_dmg = 0
			break
	
	while shields["generic"].size() > 0 and final_dmg > 0:
		#print("Detecting generic shield")
		var shield = shields["generic"][0]
		if shield.amount <= final_dmg:
			final_dmg -= shield.amount
			shields["generic"].pop_front()
			shield.remove()
		else:
			shield.amount -= final_dmg
			final_dmg = 0
			break
				
	if final_dmg < post_resist_dmg:
		var dmg_shielded = post_resist_dmg - final_dmg
		emit_signal("damage_blocked", type, dmg_shielded, self, source) 

	if final_dmg > 0.0:
		current_health -= final_dmg
		grey_health += gh_damage_ratio.total * final_dmg
		gh_timer = gh_delay.total
		emit_signal("damage_taken", type, final_dmg, self, source)

	if current_health <= 0.0:
		die()
	
	return final_dmg

func die() -> void:
	emit_signal("dying")
	queue_free()
