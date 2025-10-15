class_name Player
extends Fighter

@onready var state_machine: StateMachine = $StateMachine
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var floor_collider: CollisionShape2D = $FloorCollision

var control_schemes = [
	{
	left="ui_left",
	right="ui_right",
	up="ui_up",
	down="ui_down",
	punch="attack_1",
	kick="attack_2",
	},
	{
		left="p2_left",
		right="p2_right",
		up="p2_up",
		down="p2_down",
		punch="p2_attack_1",
		kick="p2_attack_2",
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
}

var team = "Player"

# a function that updates the controls for this class and 
func update_controls(new_controls: Object = null):
	if new_controls:
		controls = new_controls

func flip_sprite():
	if sprite == null: return
	var new_orientation = not sprite.flip_h
	sprite.flip_h = new_orientation

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
