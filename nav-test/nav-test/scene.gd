extends Node3D
const DELIVERY_AGENT = preload("uid://dkqw52pq2051d")

@onready var packed_scene =  preload("uid://cy8ymn4lwyl3j")

@onready var delivery_manager: DeliveryManager = $DeliveryManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(0,300):
		var obj = packed_scene.instantiate()
		add_child(obj)
		obj.global_position.x = randf_range(-250.0, 250.0)
		obj.global_position.z = randf_range(-250.0, 250.0)
		
	for i in range(0,20):
		var obj = DELIVERY_AGENT.instantiate()
		add_child(obj)
		(obj as DeliveryAgent).delivery_manager = delivery_manager
		obj.global_position.x = randf_range(-50.0, 50.0)
		obj.global_position.z = randf_range(-50.0, 50.0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
