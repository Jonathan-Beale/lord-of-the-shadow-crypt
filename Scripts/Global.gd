extends Node

enum StatTypes = {
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


class StatMod:
	var owner: Dummy
	var source: Dummy
	var duration: float
	var duration_remaining: float
	var stat: StatTypes
	var type: DamageTypes
	var amount: float
	var operator: Operations = Operations.PLUS

	func _init(m_source: Dummy, m_duration: float = 0.0, m_stat: StatTypes, s_amount: float, s_type: DamageTypes = none)
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
