class_name Player
extends UnitEntity

@onready var state_machine: StateMachine = $StateMachine
@onready var animation: AnimationPlayer = $Animation
@onready var sprite: AnimatedSprite2D = $Sprite

var controls = {
	left="ui_left",
	right="ui_right",
	up="ui_up",
	down="ui_down",
	punch="attack_1",
	kick="attack_2",
}

var team: String = "Player"

# a function that updates the controls for this class and 
func update_controls(new_controls: Object = null):
	if new_controls:
		controls = new_controls

func _ready():
	self.add_to_group(team)
	print(team)
	state_machine.init()

func _process(delta):
	super(delta)
	state_machine.process_frame(delta)

func _physics_process(delta):
	state_machine.process_physics(delta)

func _input(event: InputEvent):
	state_machine.process_input(event)
