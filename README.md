# Lord of the Shadow Crypt
Our game is a roguelike-inspired fighting game where the player progresses through a 2d pixel art dungeon fighting ninjas and skeletons in mortal kombat/smash bros fashion, while also expanding their moveset and build each run, with the goal of defeating the evil Necromancer who lies sealed at the bottom of the crypt. If the player falls in battle they are sent back to the start of the dungeon now playing as an entirely new ninja, but are now at risk of encountering their old ninja, now resurrected by enemy necromancers as a mini boss. We have one member and a couple of friends willing to contribute audio and create a somber atmosphere that we hope will appeal to fighting game enthusiasts who want a feeling of progression.

## Game Play
**Campaign**: The player will navigate a dungeon-like overworld navigating enemies and collecting items. Combat encounters will trigger fight scenes where the player will be able to use the items they have collected. The player's health is consistent between fights making it a key resource.

**Arena**: The player competes with other players in a multi-round pvp tournament. Between each round the player will be faced with a choice of (3) items.


### Combat
The player starts with 4 basic moves but may have up to 4 more moves depending on the weapons they've picked up so far. Fighter's store *30-70% of damage* taken as **grey health** by default. When a fighter hasn't taken damage for *0.75 seconds* they begin recovering, consuming their grey health over time to *heal for 100%* of its value.

**Resources**:
 - **Health**: The player takes damage from enemy attacks and converts some of the lost health to grey health
 - **Grey Health**: While meditating or after having not taken damage for long enough grey health is converted to health
 - **Energy**: Consumed while doing certain actions like special attacks or meditating, generated while using basic attacks or passively
               or
 - **Energy**: Consumed while attacking, jumping, or dashing; generated passively or while meditating

**Basic Moves**:
 - **Punch**: applies light damage and knockback at a short range and can be performed while moving
 - **Kick**: applies heavy damage and knockback at a medium range, cannot be performed while moving
 - **Meditate**: recovers health from grey health over time. Take reduced damage while meditating, but it gets put on cooldown if you get knocked out of it
 - **Block**: Blocks the incoming attack, takes reduced damage at higher grey health ratio


### Items
There are two major kinds of items:
 - **Wearables:** items which apply effects to the player on specific event triggers. Each effect can apply multiple conditions for its duration and will keep track of its own
    - **Event Triggers**: includes on damage taken, on damage dealt, on recovery
    - **Effects**: can add shields, modify any base stat, add burn damage, single instance damage
 - **Weapons:** items which give the player a unique attack state
    - **Event Triggers**: applies abilities on the specific attack
    - **Effects**: can do anything a wearable can do
