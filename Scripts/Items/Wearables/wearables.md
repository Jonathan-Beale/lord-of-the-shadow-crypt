# What Are?
Wearable items are items that dont give the player a unique attack animation.
Wearables affect the player stats and add effects.

# What can they do?

## Updates
`func equip()` - for when the item is first equip (one time)
`func unequip()` - for when the item is uequip (one time)
`func _process(delta: float)`


### Player Signals
Each player signal sends the damage amount, type, target, and source
`user.dealt_damage.connect(_your_function)`
 - Triggers when the user deals attack damage (NOT dot damage)
`user.dot_tick.connect(_your_function)`
 - Triggers when a user deals dot damage
`user.damage_taken.connect(_your_function)`
 - Triggers when a user takes damage
