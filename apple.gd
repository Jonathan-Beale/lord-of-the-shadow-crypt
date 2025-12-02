extends Area2D

@export var item: InvItem
var player = null

func _on_interactable_area_body_entered(body: Node2D) -> void:
	print("PEEEEEEEEEE")
	if body.has_method("player"):
		print("AHHHHHHHHHH")
		player = body
		playercollect()
		await get_tree().create_timer(0.1).timeout
		self.queue_free()

func playercollect():
	player.collect(item)
