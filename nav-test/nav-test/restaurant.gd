extends MeshInstance3D

var id

	
@export var restaurant_name:String
@export var Menu:Array[FoodItem]
@onready var address: Marker3D = $Address

# array of order ids
var orders:Array[int] = []

func get_address() ->Vector3:
	return address.global_position
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
