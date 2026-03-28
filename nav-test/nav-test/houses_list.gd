extends Node3D


var houses = []
var house_count = 0
@onready var dispatcher: Dispatcher = $".."



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for nd in get_children():
		if nd.is_in_group("DeliveryAddress"):
			nd.id = house_count
			nd.dispatcher = dispatcher
			house_count += 1
			houses.append(nd)
