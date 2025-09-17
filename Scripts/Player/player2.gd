extends Player


func _ready():
	team = "Player_2"
	super()
	controls = {
		left="p2_left",
		right="p2_right",
		up="p2_up",
		down="p2_down",
		punch="p2_attack_1",
		kick="p2_attack_2",
	}
