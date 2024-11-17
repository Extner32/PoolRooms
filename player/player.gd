extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const CLIMB_SPEED = 2.0

var in_pause_menu = false

var mouse_captured := true
var mouse_vel := Vector2.ZERO
var mouse_sensitivity := 0.1

var noclip = true

@onready var head = $head


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_captured:
		var viewport_transform := get_tree().root.get_final_transform()
		
		mouse_vel += event.xformed_by(viewport_transform).relative

func _process(delta):
	global_rotation.y += deg_to_rad(-mouse_vel.x * mouse_sensitivity)
	head.rotate_x(deg_to_rad(-mouse_vel.y * mouse_sensitivity))
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	mouse_vel = Vector2.ZERO
	
	if Input.is_action_just_pressed("pause"):
		in_pause_menu = !in_pause_menu
		mouse_captured = !in_pause_menu
	
	if mouse_captured:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
		
	$CanvasLayer/Label.text = "FPS: "+str(Engine.get_frames_per_second())
	$CanvasLayer/WaterShader.visible = $head.global_position.y < 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_noclip"):
		noclip = not noclip
	
	
	if not noclip:
		set_collision_mask_value(1, true)
		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			
		$head/RayCast3D.global_position = $head.global_position
		if is_on_wall():
			$head/RayCast3D.target_position = $head/RayCast3D.to_local($head/RayCast3D.global_position-get_wall_normal())
			$head/RayCast3D.enabled = true
		else:
			$head/RayCast3D.target_position = Vector3.ZERO
			$head/RayCast3D.enabled = false
		
		print(get_wall_normal())
		if is_on_wall_only() and !$head/RayCast3D.is_colliding():
			velocity.y = CLIMB_SPEED
			
	else:
		set_collision_mask_value(1, false)
		var input_dir := Input.get_vector("left", "right", "forward", "back")
		var vertical_input := Input.get_axis("down", "up")
		var direction := (transform.basis * Vector3(input_dir.x, vertical_input, input_dir.y)).normalized()
		if direction:
			velocity = direction*SPEED
		else:
			velocity = velocity.move_toward(Vector3.ZERO, SPEED)
			
		

	move_and_slide()
