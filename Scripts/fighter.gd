class_name Fighter
extends Dummy

# Starting Stats
const START_jump_force: float = 450
const START_air_speed: float = 160	
const START_move_speed: float = 160
const START_max_speed: float = 820

# Movement Stats
var max_speed: float = START_max_speed
var move_speed: float = START_move_speed
var air_speed: float = START_air_speed
var jump_force: float = START_jump_force
var slow_resist: float = 0.0

# Attack Mods
var knockback_mod: float = 0.0
var item_bonus_damage: Array[BonusDamage] = []
var item_damage_mods: Array[DamageMod] = []
var animation_speed: float = 1.0
var crit_chance: float = 0.0

var flat_pen = {
	"fire": 0.0,
	"ice": 0.0,
	"shadow": 0.0,
	"electric": 0.0,
	"physical": 0.0
}

var percent_pen = {
	"fire": 0.0,
	"ice": 0.0,
	"shadow": 0.0,
	"electric": 0.0,
	"physical": 0.0
}

signal dealt_damage(type: String, damage: float, target: Dummy, attacker: Fighter)

# A class for additive percentile damage mods
class DamageMod:
	var owner: Fighter
	var source: Fighter
	var type: String
	var amount: float
	func _init(
			dmg_source: Fighter = null,
			dmg_amount: float = 0.0,
			dmg_type: String = "Physical",
		):
		source = dmg_source
		amount = dmg_amount
		type = dmg_type
	
	func calc_bonus(damage: float) -> float:
		return damage * amount

	func add(to_entity: Fighter):
		if owner == to_entity: return
		if owner != null:
			owner.item_damage_mods.erase(self)
		owner = to_entity
		if not owner.item_damage_mods.has(self):
			owner.item_damage_mods.append(self)

	func remove():
		if owner == null:
			return
		owner.item_damage_mods.erase(self)
		owner = null

	func delete():
		self.free()

# A class for bonus damage on hit, accute or dot
class BonusDamage:
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
			var agg = credited_source.calc_damage_mod(amount, type)
			target.take_damage(amount + agg, type, credited_source)
		else:
			var dot = Global.BurnStack.new(attacker, amount, dot_duration, type)
			dot.add(target)

	func add(to_entity: Fighter):
		if owner == to_entity: return
		if owner != null:
			owner.item_bonus_damage.erase(self)
		owner = to_entity
		if not owner.item_bonus_damage.has(self):
			owner.item_bonus_damage.append(self)

	func remove():
		if owner == null:
			return
		owner.item_bonus_damage.erase(self)
		owner = null

	func delete():
		self.free()

var crit_rng = RandomNumberGenerator.new()
func deal_damage(target: Fighter = null, dmg_type: String = "", dmg_amount: float = 0.0):
#	Deals damage amount and type based on hitbox
#	Then applies damage bonuses from items

	# Calc crit chance/damage for phys attacks
	var agg_dmg = dmg_amount
	if dmg_type == "physical":
		var crit_score = crit_rng.randf_range(0, 1.0)
		if crit_score < crit_chance:
			agg_dmg += dmg_amount * 0.75
	
#	Calc Bonus Damage
	agg_dmg += calc_damage_mod(agg_dmg, dmg_type)
	
#	Apply Damage
	var dmg_dealt = target.take_damage(agg_dmg, dmg_type, self)
	emit_signal("dealt_damage", dmg_type, dmg_dealt, target, self)
	print("Dealt ", dmg_dealt, " ",  dmg_type, " damage")
	
#	Apply Bonus Damage Effects
	for mod in item_bonus_damage:
		mod.apply(self, target)

func calc_damage_mod(amount: float, type: String) -> float:
	var agg: float = 0.0
	for mod in item_damage_mods:
		if mod.type == type:
			#print(mod.amount, " * ", amount)
			agg += mod.calc_bonus(amount)
	return agg

enum SpeedStat { MOVE, AIR, MAX, JUMP, ALL }
var speed_mods: Array[SpeedMod] = []



class SpeedMod:
	var owner: Fighter
	var source: Fighter
	var type: String
	var magnitude: float
	var stat_effected: SpeedStat
	var duration: float
	var duration_remaining: float
	var permanent: bool
	
	func _init(effect_source: Fighter, effect_type: String, effect_magnitude: float, speed_stat: SpeedStat, effect_duration = 3.0, effect_permanent = false):
		source = effect_source
		type = effect_type
		magnitude = effect_magnitude
		stat_effected = speed_stat
		duration = effect_duration
		duration_remaining = effect_duration
		permanent = effect_permanent

	func calc_effect() -> Array:
		var modifiers = [0, 0, 0, 0]
		if stat_effected == SpeedStat.MOVE or stat_effected == SpeedStat.ALL:
			modifiers[0] += magnitude
		if stat_effected == SpeedStat.AIR or stat_effected == SpeedStat.ALL:
			modifiers[1] += magnitude
		if stat_effected == SpeedStat.MAX or stat_effected == SpeedStat.ALL:
			modifiers[2] += magnitude
		if stat_effected == SpeedStat.JUMP or stat_effected == SpeedStat.ALL:
			modifiers[3] += magnitude
		#print(modifiers)
		
		if type == "slow":
			for i in range(modifiers.size()):
				modifiers[i] = -modifiers[i]
		return modifiers

	func refresh():
		duration_remaining = duration

	func add(to_entity: Fighter):
		if owner == to_entity: return
		if owner != null:
			owner.speed_mods.erase(self)
		owner = to_entity
		if not owner.speed_mods.has(self):
			owner.add_speed_mod(self)

	func remove():
		if owner == null:
			return
		owner.speed_mods.erase(self)
		owner = null

	func delete():
		self.free()

func _process(delta: float) -> void:
	super(delta)
	update_movement_stacks(delta)
	pass

func update_movement_stacks(delta: float):
	for mod in speed_mods:
		if not mod.permanent:
			mod.duration_remaining -= delta
			if mod.duration_remaining <= 0:
				mod.remove()
				print("Speed Boost Ended")
				#mod.delete()
				calc_speed_effects()

func calc_speed_effects():
#	By default boosts stack
#	Only strongest slow applies
	var boosts = [0, 0, 0, 0]
	var slows = [0, 0, 0, 0]
	for mod in speed_mods:
		var effects = mod.calc_effect()
		if mod.type == "slow":
			for i in range(effects.size()):
				var current_slow = slows[i] * (1 / (1 + slow_resist))
				if current_slow > effects[i]:
					current_slow = effects[i]
		else:
			for i in range(effects.size()):
				boosts[i] = boosts[i] + effects[i]
	air_speed = (boosts[0] + slows[0] + 1.0) * START_air_speed
	move_speed = (boosts[1] + slows[1] + 1.0) * START_move_speed
	max_speed = (boosts[2] + slows[2] + 1.0) * START_max_speed
	jump_force = (boosts[3] + slows[3] + 1.0) * START_jump_force
	#print(boosts + slows)


func add_speed_mod(mod: SpeedMod):
	if mod.permanent:
		speed_mods.append(mod)
	else:
		for i in range(speed_mods.size()):
			if speed_mods[i].permanent:
				speed_mods.insert(i, mod)
				return
			if speed_mods[i].duration_remaining > mod.duration:
				speed_mods.insert(i, mod)
				return
			elif mod.type == "slow": # Remove redundant slows on lower duration
				if speed_mods[i].type == "slow" and speed_mods[i].magnitude == mod.magnitude:
					speed_mods[i].remove()
		speed_mods.append(mod)
	calc_speed_effects()
