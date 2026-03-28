class_name DeliveryAgent
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var model: MeshInstance3D = $model
@export var dispatcher: Dispatcher
var curr_delta :float= 0.0
var activate = false
var order_id:int = -2
var current_order:CustomerOrder 
var order_collected = false
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@onready var label_3d: Label3D = %Label3D

var order_delivered_signal_flag:bool = false

func complete_order():
	order_assigned = false
	current_order = null
	order_delivered_signal_flag = true
	label_3d.text = "... waiting"
	
func has_order(order:int):
	if current_order:
		return current_order.order_id == order
	return false
	
func set_order_id(order:int):
	order_id = order
	
#=============================================================================================
func get_target_pos():
	if order_collected:
		if current_order:
			return current_order.delivery_address
	else:
		if current_order:
			return current_order.collection_address
	return Vector3.ZERO
	
	
#=============================================================================================
func compute_lookat_basis(targ:Vector3):
	var vecTo = targ - global_position
	var vec_len = vecTo.length()
	if vec_len < 0.05:
		return
	var look_targ = vecTo.normalized()*2000+position+Vector3.UP * 0.5

	model.global_basis = Basis.looking_at( look_targ, Vector3(0.0,1.0,0.0))
	#model.look_at( look_targ, Vector3.UP)

#=============================================================================================		
func _process(delta: float) -> void:
	curr_delta = delta
	# Handle jump.

var order_assigned = false
#=============================================================================================
func _physics_process(delta: float) -> void:
	if activate:
		var next_pos = navigation_agent_3d.get_next_path_position()

		compute_lookat_basis(next_pos)
		velocity = -model.global_basis.z*SPEED
	else:
		
		velocity = Vector3.ZERO
		if order_assigned == false:
			if dispatcher:
				var new_order = dispatcher.get_order()
				
				if new_order:
					current_order = new_order	
					order_assigned = true
					order_collected = false	
					label_3d.text = var_to_str(current_order.order_id) + " Collecting"	
					navigation_agent_3d.target_position = get_target_pos()	
					activate = true
		else:
			if ( current_order and (navigation_agent_3d.target_position.distance_to(current_order.delivery_address)<1.0)
				or (global_position.distance_to(current_order.delivery_address)<1.0)):
				if order_delivered_signal_flag:
					order_delivered_signal_flag = false
					
					var new_order = dispatcher.get_order()
					
					if new_order:
						current_order = new_order
						order_assigned = true
						order_collected = false	
						label_3d.text = var_to_str(new_order.order_id) + " Collecting"		
						navigation_agent_3d.target_position = get_target_pos()	
						activate = true
					else:
						order_delivered_signal_flag = true
						label_3d.text = "... waiting"
			else:
				order_collected = true
				label_3d.text = var_to_str(current_order.order_id)	+ " Delivering"	
				navigation_agent_3d.target_position = get_target_pos()	
				activate = true
	
	if not is_on_floor():
		velocity += get_gravity()*delta
		
	navigation_agent_3d.velocity = velocity
	
#=============================================================================================
func _on_navigation_agent_3d_target_reached() -> void:
	activate = false
#=============================================================================================	
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity#velocity.move_toward(safe_velocity,curr_delta*60.0)
	navigation_agent_3d.velocity = velocity
	move_and_slide()
