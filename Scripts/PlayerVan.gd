extends CharacterBody3D


const SPEED = 8.0
const JUMP_VELOCITY = 4.5
const DRIFT = 0.2

var acceleration = 0.03
# The lower this is the less the vehicle will slide
var slideDamp = 0.1
var tyreRotation = 90.0
var rideHeight = 0.25

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	 #Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	rotTyres()
	rotMovement()
	alignWithGroundNormal()
	
	move_and_slide()


func getInputDir():
	var input_dir = Input.get_vector("left", "right", "forward", "back").normalized()
	return input_dir


func rotMovement():
	# Use input to determine if forward movement or back should be applied
	# Use input to rotate on Y axis if left or right pressed
	var input_dir = getInputDir()
	var move_dir = global_transform.basis.z.normalized() * input_dir.y
	var slide_dir = global_transform.basis.x.normalized() * -input_dir.x
	var rollingSpeed = Vector3(velocity.x, 0, velocity.z).length() / 2
	
	if rollingSpeed < 0.2:
		rollingSpeed = 0
	
	# Forward or Back movement
	if input_dir.y:
		velocity.z = lerp(velocity.z, ((move_dir.z + (slide_dir.z * slideDamp)) * SPEED), acceleration)
		velocity.x = lerp(velocity.x, ((move_dir.x + (slide_dir.x * slideDamp)) * SPEED), acceleration)
		if is_on_floor():
			$BackLCPUParticles3D.emitting = true
			$BackRCPUParticles3D.emitting = true
		else:
			$BackLCPUParticles3D.emitting = false
			$BackRCPUParticles3D.emitting = false
	else:
		velocity.z = lerp(velocity.z, 0.0, 0.05)
		velocity.x = lerp(velocity.x, 0.0, 0.05)
		$BackLCPUParticles3D.emitting = false
		$BackRCPUParticles3D.emitting = false
	
	# Left and Right rotation
	if input_dir.x and rollingSpeed > 0.2:
		# This just makes the turn speed faster or slower depending on how fast the vehicle is moving
		var turnSpeed = clamp((0.01 * rollingSpeed), 0, 0.02)
		# Rotates the transform based on the x input
		transform.basis = transform.basis.rotated(Vector3(0,1,0), (-input_dir.x * turnSpeed))


func rotTyres():
	var input_dir = getInputDir()
	if input_dir.x > 0:
		if input_dir.y > 0:
			tyreRotation = lerp(tyreRotation, 110.0, 0.1)
		else:
			tyreRotation = lerp(tyreRotation, 60.0, 0.1)
	elif input_dir.x < 0:
		if input_dir.y > 0:
			tyreRotation = lerp(tyreRotation, 60.0, 0.1)
		else:
			tyreRotation = lerp(tyreRotation, 110.0, 0.1)
	else:
		tyreRotation = lerp(tyreRotation, 90.0, 0.2)
	$WheelFrontLMesh.set_rotation_degrees(Vector3(90,tyreRotation,0))
	$WheelFrontRMesh.set_rotation_degrees(Vector3(90,tyreRotation,0))


func alignWithGroundNormal():
	if $GroundRayCast3D.is_colliding():
		var normal = $GroundRayCast3D.get_collision_normal()
		var xform = align_with_y(global_transform, normal)
		global_transform = global_transform.interpolate_with(xform, 0.1)


func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

