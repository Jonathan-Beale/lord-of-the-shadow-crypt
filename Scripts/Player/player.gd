class_name Player
extends Fighter

@onready var state_machine: StateMachine = $StateMachine
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var floor_collider: CollisionShape2D = $FloorCollision

#SFX
@onready var jump_sfx: AudioStreamPlayer = $JumpSound
@onready var light_attack_sound: AudioStreamPlayer = $LightAttackSound
@onready var heavy_attack_sound: AudioStreamPlayer = $HeavyAttackSound
@onready var impact_sound: AudioStreamPlayer = $ImpactSound
@onready var stone_footstep_sound: AudioStreamPlayer = $StoneFootstepSound


var control_schemes = [
	{
	left="ui_left",
	right="ui_right",
	up="ui_up",
	down="ui_down",
	punch="attack_1",
	kick="attack_2",
	slash="attack_3",
	block="p1_block",
	dash="dash",
	heavy="heavy_attack",
	nun = "nun_attack"
	},
	{
		left="p2_left",
		right="p2_right",
		up="p2_up",
		down="p2_down",
		punch="p2_attack_1",
		kick="p2_attack_2",
		slash="p2_attack_3",
		block="p2_block",
		dash = "p2_dash",
		heavy="p2_heavy_attack",
		nun = "p2_nun_attack"
		
	},
	{
		left="p3_left",
		right="p3_right",
		up="p3_up",
		down="p3_down",
		punch="p3_attack_1",
		kick="p3_attack_2",
	},
	{
		left="p4_left",
		right="p4_right",
		up="p4_up",
		down="p4_down",
		punch="p4_attack_1",
		kick="p4_attack_2",
	}
]
var teams = [
	"Team 1",
	"Team 2",
]
var controls = {
	left="ui_left",
	right="ui_right",
	up="ui_up",
	down="ui_down",
	punch="attack_1",
	kick="attack_2",
	slash="attack_3",
	block="p1_block",
	dash="dash",
	heavy="heavy_attack",
	nun = "nun_attack"
}

var team = "Player"

# a function that updates the controls for this class and 
func update_controls(new_controls: Object = null):
	if new_controls:
		controls = new_controls

func _ready():
	self.add_to_group("Player")
	
	var players = get_tree().get_nodes_in_group("Player")
	var index = players.size() - 1
	controls = control_schemes[index]
	assign_team(teams[index])
	
	state_machine.init()
	


func _process(delta):
	super(delta)
	state_machine.process_frame(delta)

func _physics_process(delta):
	state_machine.process_physics(delta)

func _input(event: InputEvent):
	state_machine.process_input(event)

func assign_team(new_team: String = ""):
	if not new_team: return
	team = new_team
	self.add_to_group(team)

func play_jump_sfx():
	jump_sfx.play()

func play_light_attack_sound():
	light_attack_sound.play()

func play_heavy_attack_sound():
	heavy_attack_sound.play()

func play_impact_sound():
	impact_sound.play()
	
func play_stone_footstep_sound():
	stone_footstep_sound.play()
