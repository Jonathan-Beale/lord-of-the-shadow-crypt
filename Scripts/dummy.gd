class_name Dummy
extends CharacterBody2D
"""
A Class that has durability mods and takes/blocks damage
"""


# Health Stats
const START_HEALTH: float = 1000.0
var current_health: float = START_HEALTH
var max_health: float = START_HEALTH

# Grey Health Trackers
var grey_health: float = 0.0
var gh_timer: float = 0.0

# Grey Health Mods
var gh_damage_ratio: float = 0.5 # ratio at which damage taken is converted to grey health
var gh_heal_ratio: float = 0.5 # ratio at whih grey health is converted to health
var gh_recovery_rate: float = 0.05 # rate at which grey health recovers
var gh_delay: float = 3.0 # delay before grey health healing begins

var anti_heal: float = 0.0
var heal_power: float = 0.0

enum DummyStatTypes = {
	CURRENT_HEALTH,
	MAX_HEALTH,
	GREY_HEALTH,
	GH_DAMAGE_RATIO,
	GH_HEAL_RATIO,
	GH_RECOVERY_RATE,
	GH_DELAY,
	RESIST,
	SHIELD,
	ANIT_HEAL,
	HEAL_POWER
}

signal damage_blocked(type: String, damage: float, target: Dummy, attacker: Fighter)
signal recovering()

func modify_stat(stat, amount, type, operator):
	if stat = DummyStatTypes.CURRENT_HEALTH:
		current_health = operate(current_health, amount, operator)
	elif stat = DummyStatTypes.MAX_HEALTH:
		max_health = operate(max_health, amount, operator)
	elif stat = DummyStatTypes.GREY_HEALTH:
		grey_health = operate(grey_health, amount, operator)
	elif stat = DummyStatTypes.GH_DAMAGE_RATIO:
		gh_damage_ratio = operate(gh_damage_ratio, amount, operator)
	elif stat = DummyStatTypes.GH_HEAL_RATIO:
		gh_heal_ratio = operate(gh_heal_ratio, amount, operator)
	elif stat = DummyStatTypes.GH_RECOVERY_RATE:
		gh_recovery_rate = operate(gh_recovery_rate, amount, operator)
	elif stat = DummyStatTypes.GH_DELAY:
		gh_delay = operate(gh_delay, amount, operator)
	elif stat = DummyStatTypes.RESIST:
		if not type: return
		resists[type] = operate(resists[type], amount, operator)
	elif stat = DummyStatTypes.SHIELD:
		if not type: shields["generic"] = operate(shields["generic"], amount, operator)
		else: shields[type] = operate(shields[type], amount, operator)
	elif stat = DummyStatTypes.ANTI_HEAL:
		anti_heal = operate(anti_heal, amount, operator)
	elif stat = DummyStatTypes.HEAL_POWER:
		heal_power = operate(heal_power, amount, operator)

# Shields
var shields = {
	"generic": 0.0
	"fire": 0.0,
	"ice": 0.0,
	"shadow": 0.0,
	"electric": 0.0,
	"physical": 0.0
}

# Resistance Stats
var resists = {
	"fire": 25.0,
	"ice": 25.0,
	"shadow": 25.0,
	"electric": 25.0,
	"physical": 50.0
}

enum Operations = {
	ADD,
	MULTIPLY
}

var update_needed: bool = false
var stat_mods: Array[DummyStatMod] = []

class DummyStatMod:
	var owner: Dummy
	var source: Dummy
	var duration: float
	var duration_remaining: float
	var stat: DummyStatTypes
	var type: DamageTypes
	var amount: float
	var operator: Operations = Operations.PLUS

	func _init(m_source: Dummy, m_duration: float = 0.0, m_stat: DummyStatTypes, s_amount: float, s_type: DamageTypes = none)
		source = m_source
		duration = m_duration
		duration_remaining duration
		stat = m_stat
		amount = s_amount
		type = s_type

	func add(to_entity: Dummy):
		if owner == to_entity: return
		if owner != null:
			owner.stat_mods.erase(self)
		owner = to_entity
		if not owner.stat_mods.has(self):
			owner.add_mod(self)
		owner.modify_stat(stat, amount, type, operator)

	func remove():
		if owner == null:
			return
		if operator == Operations.PLUS:
			owner.modify_stat(stat, amount, type, operator)
		elif operator == Operations.MULTIPLY:
			owner.modify_stat(stat, (1 / amount), type, operator)

		owner.stat_mods.erase(self)
		owner = null

	func delete():
		self.free()

func add_mod(mod: DummyStatMod)
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

func operate(stat: float, amount: float, operator: Operations) -> float:
	if operator == Operations.ADD:
		return stat + amount
	elif operator == Operations.MULTIPLY:
		return stat * amount


# --- DoT system --------------------------------------------------------------
# One manager list, updated once per frame. No Timer nodes per effect.
# amount is DPS (damage per second) by default.
var _dots: Array = []  # Array[Dictionary]

enum DotStacking { REFRESH, STACK_DPS, STACK_DURATION }
const DOT_TICK: float = 0.25         # seconds between ticks (feels snappy, not spammy)
const DOT_MAX_STACKS_DEFAULT := 5

signal dot_applied(type: String, stacks: int, dps: float, duration_left: float)
signal dot_tick(type: String, damage: float, target: Dummy, source: Fighter)
signal dot_expired(type: String)
signal damage_taken(type: String, amount: float, target: Dummy, source: Fighter)
signal healing_done(amount: float, source: Node2D)

func add_dot(
	amount: float,
	duration: float,
	type: String = "fire",
	source: Node = null,
	stacking: DotStacking = DotStacking.STACK_DPS,
	max_stacks: int = DOT_MAX_STACKS_DEFAULT,
	tick_rate: float = DOT_TICK
) -> void:
	#print("Applying dot")
	# 'amount' is DPS (damage per second).
	var dot = _find_dot(type, source)
	if dot:
		match stacking:
			DotStacking.REFRESH:
				dot.duration_left = max(dot.duration_left, duration)
				dot.dps = max(dot.dps, amount)
			DotStacking.STACK_DPS:
				if dot.stacks < dot.max_stacks:
					dot.stacks += 1
					dot.dps += amount
				# always refresh a little to feel responsive
				dot.duration_left = max(dot.duration_left, duration)
			DotStacking.STACK_DURATION:
				dot.duration_left = min(dot.duration_left + duration, duration * max_stacks)
				dot.dps = max(dot.dps, amount)
		emit_signal("dot_applied", type, dot.stacks, dot.dps, dot.duration_left, dot.source)
	else:
		_dots.append({
			"type": type,
			"source": source,
			"dps": amount,
			"duration_left": duration,
			"tick_rate": tick_rate,
			"tick_accum": 0.0,
			"stacks": 1,
			"max_stacks": max_stacks
		})
		emit_signal("dot_applied", type, 1, amount, duration)

func clear_dot(type: String, source: Node = null) -> void:
	for i in range(_dots.size() - 1, -1, -1):
		var d = _dots[i]
		if d.type == type and d.source == source:
			_dots.remove_at(i)
			d.source.emit_signal("dot_expired", type)

func has_dot(type: String) -> bool:
	for d in _dots:
		if d.type == type:
			return true
	return false

func _process(delta: float) -> void:
	_update_grey_health(delta)
	_update_dots(delta)
	if update_needed:	_update_mods(delta)

func _update_grey_health(delta: float):
	if gh_timer > 0.0:
		gh_timer -= delta
		if gh_timer <= 0.0
			gh_timer = 0.0
			emit_signal("recovering")
		return
	if grey_health <= 0.0:
		return
	var gh_used = max_health * gh_recovery_rate * delta
	if gh_used > grey_health: gh_used = grey_health
	grey_health -= gh_used
	var healing = gh_used * gh_heal_ratio
	print("Recovering ", healing, " health")
	heal(healing)

func heal(amount: float, source = self):
	var final_healing = amount * (1 - anti_heal) * (1 + heal_power)
	emit_signal("healing_done", amount, source)
	current_health += final_healing

func _update_dots(delta: float) -> void:
	#print("Updating dot")
	for i in range(_dots.size() - 1, -1, -1):
		var d = _dots[i]
		d.tick_accum += delta
		d.duration_left -= delta

		# Tick in fixed steps so damage is stable regardless of framerate
		while d.tick_accum >= d.tick_rate and d.duration_left > 0.0:
			d.tick_accum -= d.tick_rate
			var interval: float = d.tick_rate
			var base_damage: float = d.dps * interval  # DPS -> damage over this interval
			# Let take_damage apply resistances once
			var agg: float = d.source.calc_damage_mod(base_damage, d.type)
			var dmg = agg + base_damage
			#print("Dealing ", agg, " Bonus Damage")
			take_damage(dmg, d.type, d.source)
			d.source.emit_signal("dot_tick", d.type, dmg, self, d.source)

		if d.duration_left <= 0.0:
			_dots.remove_at(i)
			d.source.emit_signal("dot_expired", d.type)

func _find_dot(type: String, source: Node) -> Dictionary:
	for d in _dots:
		# Stacking identity: by type+source (so different casters can apply separate DoTs)
		# If you want type-only, drop the source check.
		if d.type == type and d.source == source:
			return d
	return {}

# --- Damage / death ----------------------------------------------------------
func take_damage(amount: float, type: String = "physical", source: Fighter = null) -> float:
	var r := float(resists.get(type, 100.0))

	# Apply source armor pen
	r -= r * source.percent_pen[type]
	r -= source.flat_pen[type]
	r = max(r, 0.0) # avoid negatives
	var resist_quotient := 100.0 / (100.0 + r)
	var final_dmg = amount * resist_quotient

	# Shield damage reduction
	var dmg_shielded = 0.0
	if shields[type] > 0.0: # type pecific shield
		if shields[type] < final_dmg:
			dmg_shielded += shields[type]
			final_dmg -= shields[type]
			shields[type] = 0
		else:
			dmg_shielded += final_dmg
			shields[type] -= final_dmg
			final_dmg = 0
	if shields["all"] > 0.0: # general shield
		if shields["all"] < final_dmg:
			final_dmg -= shields["all"]
			shields["all"] = 0
		else:
			shields["all"] -= final_dmg
			final_dmg = 0
	if dmg_shielded > 0.0:
		final_dmg -= dmg_shielded
		emit_signal("damage_blocked", type, dmg_shielded, self, source) 

	current_health -= final_dmg
	grey_health += gh_damage_ratio * final_dmg
	gh_timer = gh_delay
	emit_signal("damage_taken", type, amount, self, source)
	if current_health <= 0.0:
		die()
	return amount

func die() -> void:
	queue_free()
