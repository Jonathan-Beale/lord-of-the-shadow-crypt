class_name Dummy
extends CharacterBody2D

# Health Stats
const START_HEALTH: float = 1000.0
var current_health: float = START_HEALTH
var max_health: float = START_HEALTH

# Resistance Stats
var resists = {
	"fire": 100,
	"ice": 100,
	"shadow": 100,
	"electric": 100,
	"physical": 100
}

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
	r = max(r, 1.0) # avoid div by zero / negative
	var resist_quotient := 100.0 / r
	current_health -= amount * resist_quotient
	emit_signal("damage_taken", type, amount, self, source)
	if current_health <= 0.0:
		die()
	return amount

func die() -> void:
	queue_free()
