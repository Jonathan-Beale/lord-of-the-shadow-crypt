class_name Wearable
extends Node2D

@onready var user: Fighter = get_owner()
var item_stats = {}
var active_cooldowns: Array[ItemEffect] = []


func _ready():
	print("Wearable ready")
	self.add_to_group("Wearable")
	user.recovering.connect(_on_recover)
	equip()
	item_stats = load_item_stats("res://Scripts/Items/Wearables/json/example_wearable.json")
	print("Item stats:", item_stats)


class ItemEffect:
	var owner
	var user
	var trigger: String
	var mods: Array = []
	var damage: Array = []
	var cooldown: float = 0.0
	var condition: String = ""
	var remaining_cooldown: float = 0.0
	var max_stacks: int = 1
	var current_stacks: int = 0
	var active_mods: Array = []

	func _init(e_trigger, e_mods, e_damage, c, cd=0.0, ms=1):
		trigger = e_trigger
		mods = e_mods
		damage = e_damage
		condition = c
		cooldown = cd
		max_stacks = ms
		if trigger == "on_hurt":
			user.damage_taken.connect(_on_hurt)
		if trigger == "on_dot" or trigger == "on_hit":
			user.dot_tick.connect(_on_damage)

	func add(to_entity: Wearable):
		if owner == to_entity: return
		owner = to_entity
		user = owner.user
	
	func connect_signals():
		if trigger == "on_dot":
			user.dot_tick.connect(_on_damage)
			return
		if trigger == "on_hit":
			user.dealt_damage.connect(_on_damage)
			return
		if trigger == "on_hurt":
			user.damage_taken.connect(_on_hurt)
			return
		if trigger == "on_block":
			user.damage_blocked.connect(_on_hurt)
			return
		if trigger == "on_recover":
			user.recovering.connect(apply)
			return
		# if trigger == "passive":
		# 	apply(null, 0.0, user, null)
		# 	return
		if trigger == "on_equip":
			apply(null, 0.0, null)
			return

	func _on_damage(damage_type, amount, target: Dummy, _source: Fighter) -> void:
		if condition == "any" or condition == "":
			apply(damage_type, amount, target)
			return
		if damage_type == condition:
			apply(damage_type, amount, target)
			return

	func _on_hurt(damage_type, amount, _target: Dummy, source: Fighter) -> void:
		if condition == "any" or condition == "":
			apply(damage_type, amount, source)
			return
		if damage_type == condition:
			apply(damage_type, amount, source)
			return

	func apply(_damage_type = null, amount = null, _trigger_entity: Dummy = null):
		# Check cooldowns
		if remaining_cooldown > 0.0:
			return
		if cooldown > 0.0:
			owner.active_cooldowns.append(self)
			remaining_cooldown = cooldown
		
		if current_stacks == 0:
			for mod in mods:
				if mod["type"] == "shield":
					var shield = Global.Shield.new(mod["amount"], mod["duration"], mod["type"])
					shield.add(user)
					active_mods.append(shield)
				if mod["type"] == "stat":
					var stat_mod = Global.StatMod.new(mod["stat"], user, mod["amount"], mod["type"], mod["duration"])
					stat_mod.add(user)
					active_mods.append(stat_mod)

			for dmg in damage:
				if dmg["duration"] > 0.0:
					var dot = Global.BurnStack.new(user, dmg["amount"], dmg["duration"], dmg["type"])
					dot.add(_trigger_entity)
				else:
					_trigger_entity.take_damage(dmg["amount"], dmg["type"], user)
		else:
			if current_stacks >= max_stacks:
				return
			current_stacks += 1
			for mod in active_mods:
				mod.apply_stack()	

			for dmg in damage:
				if dmg["duration"] > 0.0:
					var dot = Global.BurnStack.new(user, dmg["amount"], dmg["duration"], dmg["type"])
					dot.add(_trigger_entity)
				else:
					_trigger_entity.take_damage(dmg["amount"], dmg["type"], user)

func load_item_stats(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("File not found: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("Could not open file: %s" % path)
		return {}

	var text := file.get_as_text()
	file.close()

	var result = JSON.parse_string(text)
	if result == null:
		push_error("JSON parse failed for: %s" % path)
		return {}

	return result

func connect_signals():
	if on_damage_effects.length() > 0:
		user.dealt_damage.connect(on_damage)
	if on_block_effects.length() > 0:
		user.damage_blocked.connect(on_blocked)
	if on_hurt_effects.length() > 0:
		user.damage_taken.connect(on_hurt)
	if on_dot_effects.length() > 0:
		user.dot_tick.connect(on_dot)
	if on_recover_effects.length() > 0:
		user.recovering.connect(_on_recover)

func _process(delta: float) -> void:
#	test item makes you heal 10 + 2% missing health per second
	#if user.current_health < user.max_health:
		#var missing_health = user.max_health - user.current_health
		#user.current_health += (10 + 0.02 * missing_health) * delta
	pass

func equip():
#	user.max_health += 1000
	pass

func unequip():
#	user.max_health -= 1000
	pass

func add_mod_effect(stat, amount, type, duration):
	var mod = Global.StatMod.new(stat, user, amount, type, duration)
	#pass
	user.add_mod(mod)

var on_damage_effects = []
func on_damage():
	pass

var on_dot_effects = []
func on_dot():
	pass

var on_block_effects = []
func on_blocked():
	pass

var on_hurt_effects = []
func on_hurt():
	pass

var on_recover_effects = []
func _on_recover():
	var duration = 0.0
	var amount = user.grey_health / 2
	user.grey_health -= amount
	var shield = Global.Shield.new(user, amount, duration)
	shield.add(user)

# Loadable from json
# % health burn
# on damage type
# burn type
# burn amount
# max stacks
