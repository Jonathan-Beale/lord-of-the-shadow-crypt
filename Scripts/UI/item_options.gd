extends ColorRect

var options = []

func generate_options(item_type = "wearable"):
#	select 3 items as item options
	if item_type == "wearable":
		pass
	pass

func retrieve_random_item(item_type: String = "wearable"):
	if item_type == "wearable":
		var dir := DirAccess.open("res://Scripts/Items/Wearables/json/")
		pass
	pass
