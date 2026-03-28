extends Node3D

var restaurants = []
var count=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var rnd = get_children().pick_random()
	for nd in get_children():
		if nd.is_in_group("Restaurant"):
			nd.id = count
			count += 1
			#restaurants.append(nd)
			
func get_random():
	return get_children().pick_random()
	
func get_restaurant(id:int):
	for e in get_children():
		if e.id == id:
			return e
	return null
