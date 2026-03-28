extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var model: MeshInstance3D = $model
var curr_delta :float= 0.0
var activate = false
#=============================================================================================
func rand_pos_in_zone(pos_min:float, pos_max:float):
	return Vector3( randf_range(pos_min,pos_max), 0.0, randf_range(pos_min,pos_max))
#=============================================================================================
func compute_lookat_basis(targ:Vector3):
	var vecTo = targ - global_position
	var vec_len = vecTo.length()
	if vec_len < 0.05:
		return
	var look_targ = vecTo.normalized()*2000+global_position+Vector3.UP * 0.5
	
	model.global_basis = Basis.looking_at( look_targ, Vector3(0.0,1.0,0.0))
#=============================================================================================
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") :#and is_on_floor():
		navigation_agent_3d.target_position = rand_pos_in_zone(-250.0, 250.0)
		activate = true
#=============================================================================================		
func _process(delta: float) -> void:
	curr_delta = delta
	# Handle jump.

#=============================================================================================
func _physics_process(delta: float) -> void:
	if activate:
		var next_pos = navigation_agent_3d.get_next_path_position()

		compute_lookat_basis(next_pos)
		velocity = -model.global_basis.z*SPEED
	else:
		navigation_agent_3d.target_position = rand_pos_in_zone(-250.0, 250.0)
		velocity = Vector3.ZERO
		activate = true
	
	if not is_on_floor():
		velocity += get_gravity()*delta
		
	navigation_agent_3d.velocity = velocity
	
#=============================================================================================
func _on_navigation_agent_3d_target_reached() -> void:
	activate = false
#=============================================================================================	
func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity#velocity.move_toward(safe_velocity,curr_delta*120.0)
	navigation_agent_3d.velocity = velocity
	move_and_slide()
