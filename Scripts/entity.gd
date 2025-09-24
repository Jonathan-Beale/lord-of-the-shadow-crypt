class_name Fighter
extends CharacterBody2D

const START__HEALTH: float = 1000.0
var current_health: float = START__HEALTH
var max_health: float = START__HEALTH
var resists = {
	"fire": 100,
	"ice": 100,
	"shadow": 100,
	"electric": 100,
	"physical": 100
}

var global_damage_mods: Array = []

class DamageMod:
	var owner: Fighter
	var source: Fighter
	var amount: float
	var type: String
	var dot: bool
	var dot_duration: float
	func _init(
			dmg_source: Fighter = null,
			dmg_amount: float = 0.0,
			dmg_type: String = "Physical",
			dmg_dot: bool = false,
			dmg_duration: float = 0.0
		):
		source = dmg_source
		amount = dmg_amount
		type = dmg_type
		dot = dmg_dot
		dot_duration = dmg_duration

	func apply(attacker: Fighter = null, target: Fighter = null):
		var credited_source := source if source else attacker
		if not dot:
			target.take_damage(amount, type)
		else:
			target.add_dot(amount, dot_duration, type, credited_source)

	func add(to_entity: Fighter):
		if owner == to_entity: return
		if owner != null:
			owner.global_damage_mods.erase(self)
		owner = to_entity
		if not owner.global_damage_mods.has(self):
			owner.global_damage_mods.append(self)

	func remove():
		if owner == null:
			return
		owner.global_damage_mods.erase(self)
		owner = null

	func delete():
		self.free()

# --- DoT system --------------------------------------------------------------
# One manager list, updated once per frame. No Timer nodes per effect.
# amount is DPS (damage per second) by default.
var _dots: Array = []  # Array[Dictionary]

enum DotStacking { REFRESH, STACK_DPS, STACK_DURATION }
const DOT_TICK: float = 0.25         # seconds between ticks (feels snappy, not spammy)
const DOT_MAX_STACKS_DEFAULT := 5

signal dot_applied(type: String, stacks: int, dps: float, duration_left: float)
signal dot_tick(type: String, damage: float, stacks: int)
signal dot_expired(type: String)

func add_dot(
	amount: float,
	duration: float,
	type: String = "fire",
	source: Node = null,
	stacking: DotStacking = DotStacking.STACK_DPS,
	max_stacks: int = DOT_MAX_STACKS_DEFAULT,
	tick_rate: float = DOT_TICK
) -> void:
	print("Applying dot")
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
		emit_signal("dot_applied", type, dot.stacks, dot.dps, dot.duration_left)
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
			emit_signal("dot_expired", type)

func has_dot(type: String) -> bool:
	for d in _dots:
		if d.type == type:
			return true
	return false

func _process(delta: float) -> void:
	_update_dots(delta)

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
			take_damage(base_damage, d.type)
			emit_signal("dot_tick", d.type, base_damage, d.stacks)

		if d.duration_left <= 0.0:
			_dots.remove_at(i)
			emit_signal("dot_expired", d.type)

func _find_dot(type: String, source: Node) -> Dictionary:
	for d in _dots:
		# Stacking identity: by type+source (so different casters can apply separate DoTs)
		# If you want type-only, drop the source check.
		if d.type == type and d.source == source:
			return d
	return {}

# --- Damage / death ----------------------------------------------------------
func take_damage(amount: float, type: String = "physical") -> void:
	var r := float(resists.get(type, 100.0))
	r = max(r, 1.0) # avoid div by zero / negative
	var resist_quotient := 100.0 / r
	current_health -= amount * resist_quotient
	if current_health <= 0.0:
		die()

func deal_damage(hitbox: HitBox = null, target: Fighter = null):
	if not hitbox or not target:
		return
	target.take_damage(hitbox.DAMAGE, "physical")
	for mod in global_damage_mods:
		mod.apply(self, target)

func die() -> void:
	queue_free()
