extends MeshInstance3D

var id 
var order_id = -1
@onready var delivery_area: Area3D = $Address/Area3D
@onready var address: Marker3D = $Address
var delivery_manager : DeliveryManager 
func get_address()->Vector3:
	return address.global_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	delivery_area.connect("body_entered",on_delivery)




func on_delivery(body:Node3D):
	if body is DeliveryAgent:
		if (body as DeliveryAgent).has_order(order_id):
			(body as DeliveryAgent).complete_order()
			delivery_manager.complete_order(order_id)
			order_id = -1
