class_name DeliveryAgent
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var model: MeshInstance3D = $model
@export var delivery_manager: DeliveryManager
var curr_delta :float= 0.0
var activate = false
var order_id:int = -2
var current_order:CustomerOrder = null
var order_collected = false
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

@onready var label_3d: Label3D = %Label3D


func complete_order():
	order_assigned = false
	current_order = null
func has_order(order:int):
	return order == order_id
func set_order_id(order:int):
	order_id = order
	
#=============================================================================================
func rand_pos_in_zone(min:float, max:float):
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
	var len = vecTo.length()
	if len < 0.05:
		return
	var look_targ = vecTo*2000+global_position
	
	model.look_at(look_targ)
#=============================================================================================
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") :#and is_on_floor():
		navigation_agent_3d.target_position = rand_pos_in_zone(-90.0, 90.0)
		activate = true
#=============================================================================================		
func _process(delta: float) -> void:
	curr_delta = delta
	# Handle jump.

var order_assigned = false
#=============================================================================================
func _physics_process(delta: float) -> void:
	if activate:
		var next_pos = navigation_agent_3d.get_next_path_position()
		var vecTo = next_pos - global_position
		compute_lookat_basis(next_pos)
		velocity = -model.global_basis.z*SPEED
	else:
		
		velocity = Vector3.ZERO
		if order_assigned == false:
			if delivery_manager:
				current_order = delivery_manager.get_order()	
				if current_order:
					order_assigned = true
					order_collected = false	
					label_3d.text = var_to_str(current_order.order_id) + " Collecting"	
					navigation_agent_3d.target_position = rand_pos_in_zone(-90.0, 90.0)	
					activate = true
		else:
			if ( current_order and (navigation_agent_3d.target_position.distance_to(current_order.delivery_address)<1.0)
				or (global_position.distance_to(current_order.delivery_address)<1.0)):
				order_collected = false
				current_order = delivery_manager.get_order()
				if current_order:
					order_assigned = true
					order_collected = false	
					label_3d.text = var_to_str(current_order.order_id) + " Collecting"		
					navigation_agent_3d.target_position = rand_pos_in_zone(-90.0, 90.0)	
					activate = true
			else:
				order_collected = true
				label_3d.text = var_to_str(current_order.order_id)	+ " Delivering"	
				navigation_agent_3d.target_position = rand_pos_in_zone(-90.0, 90.0)	
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
	navigation_agent_3d.velocity = safe_velocity
	move_and_slide()
