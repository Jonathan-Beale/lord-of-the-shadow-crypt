extends Area2D


@export var next_level_path : String = "res://assetsOW/ScenesOW/crypt_lvl.tscn"


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file(next_level_path) # Replace with function body.
