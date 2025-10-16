class_name Global
extends Node


enum Operations {
	ADD,
	MULTIPLY
}

enum StatTypes {
	CURRENT_HEALTH,
	MAX_HEALTH,
	GREY_HEALTH,
	GH_DAMAGE_RATIO,
	GH_HEAL_RATIO,
	GH_RECOVERY_RATE,
	GH_DELAY,
	RESIST,
	SHIELD,
	ANTI_HEAL,
	HEAL_POWER,
	MAX_SPEED,
	MOVE_SPEED,
	AIR_SPEED,
	JUMP_FORCE,
	SLOW_RESIST,
	KNOCKBACK,
	ANIMATION_SPEED,
	CRIT_CHANCE,
	FLAT_PEN,
	PERCENT_PEN
}

class ModBase:
	var owner: Dummy
	var source: Dummy
	var duration: float # 0 for single instance damage
	var duration_remaining: float
	var type: String # type of damage
	var current_magnitude: float = 0.0
	var amount: float # TODO: rename to magnitude
	var stacks: int = 0
	var max_stacks: int = 1

	func _init(m_source: Dummy, s_amount: float, s_type: String = "generic", m_duration: float = 0.0):
		source = m_source
		duration = m_duration
		duration_remaining = duration
		type = s_type
		amount = s_amount

	func add(to_entity: Dummy):
		if owner == to_entity: return
		if owner != null:
			owner.stat_mods.erase(self)
		owner = to_entity
		if not owner.stat_mods.has(self):
			owner.add_mod(self)

	func remove():
		if owner == null:
			return
		owner.stat_mods.erase(self)
		owner = null

	func apply_stack():
		if stacks < max_stacks:
			stacks += 1
		duration_remaining = duration
		current_magnitude += amount
		var c_owner = owner
		self.remove()
		self.add(c_owner)

	#func delete():
		#self.free()

class Shield extends ModBase:
	func _init(m_source: Dummy, s_amount: float = 0.0, s_duration: float = 0.0, s_type: String =  "generic"):
		super._init(m_source, s_amount, s_type, s_duration)
	
	func add(to_entity: Dummy):
		if owner == to_entity: return
		if owner != null:
			owner.shields[type].erase(self)
		owner = to_entity
		if not owner.shields[type].has(self):
			owner.add_shield(self)
	
	func remove():
		if owner == null:
			return
		owner.shields[type].erase(self)
		owner = null

	func apply_stack():
		if int(current_magnitude) % int(amount) != 0:
			stacks = int(current_magnitude / amount) + 1
		else:
			stacks = int(current_magnitude / amount)

		if stacks < max_stacks:
			stacks += 1
		duration_remaining = duration
		current_magnitude += amount
		var c_owner = owner
		self.remove()
		self.add(c_owner)	

class BurnStack extends ModBase:
	var damage_per_second: float = 0.0

	func _init(m_source: Dummy, dps: float = 0.0, s_duration: float = 0.0, s_type: String = "fire"):
		super._init(m_source, dps, s_type, s_duration)
		damage_per_second = dps

	func add(to_entity: Dummy):
		if owner == to_entity: return
		if owner != null:
			owner.dot_mods.erase(self)
		owner = to_entity
		if not owner.dot_mods.has(self):
			owner.dot_mods.append(self)

	func remove():
		if owner == null:
			return
		owner.dot_mods.erase(self)
		owner = null

	func apply_stack():
		if stacks < max_stacks:
			stacks += 1
		duration_remaining = duration

class StatMod extends ModBase:
	var stat: String
	var operator: Operations = Operations.ADD

	func _init(m_stat: String, m_source: Dummy, s_amount: float, s_type: String = "generic", m_duration: float = 0.0):
		super._init(m_source, s_amount, s_type, m_duration)
		stat = m_stat

	func add(to_entity: Dummy):
		super.add(to_entity)
		owner.modify_stat(stat, current_magnitude, type, operator)
