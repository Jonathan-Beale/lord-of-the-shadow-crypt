class_name Fighter
extends Dummy

# Movement Stats
const START_jump_force: float = 450
var jump_force: float = START_jump_force
const START_air_speed: float = 160	
var air_speed: float = START_air_speed
const START_move_speed: float = 160
var move_speed: float = START_move_speed
const START_max_speed: float = 820
var max_speed: float = START_max_speed

# Attack Mods
var knockback_mod: float = 0.0
var item_bonus_damage: Array[BonusDamage] = []
var item_damage_mods: Array[DamageMod] = []


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
			target.add_dot(amount, dot_duration, type, credited_source)

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

func deal_damage(target: Fighter = null, dmg_type: String = "", dmg_amount: float = 0.0):
#	Deals damage amount and type based on hitbox
#	Then applies damage bonuses from items
	
#	Calc Bonus Damage
	var agg_bonus_dmg = calc_damage_mod(dmg_amount, dmg_type)
	
#	Apply Damage
	var dmg_dealt = target.take_damage(dmg_amount + agg_bonus_dmg, dmg_type, self)
	emit_signal("dealt_damage", dmg_type, dmg_dealt, target, self)
	print("Dealt ", dmg_amount, " ",  dmg_type, " damage")
	
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
	var duration_left: float
	var permanent: bool
	
	func _init(effect_source: Fighter, effect_type: String, effect_magnitude: float, speed_stat: SpeedStat, effect_duration = 3.0, effect_permanent = false):
		source = effect_source
		type = effect_type
		magnitude = effect_magnitude
		stat_effected = speed_stat
		duration = effect_duration
		duration_left = effect_duration
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
		duration_left = duration

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
			mod.duration_left -= delta
			if mod.duration_left <= 0:
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
				if slows[i] > effects[i]:
					slows[i] = effects[i]
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
			if speed_mods[i].duration_left > mod.duration:
				speed_mods.insert(i, mod)
				return
			elif mod.type == "slow": # Remove redundant slows on lower duration
				if speed_mods[i].type == "slow" and speed_mods[i].magnitude == mod.magnitude:
					speed_mods[i].remove()
		speed_mods.append(mod)
	calc_speed_effects()
