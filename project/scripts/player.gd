extends CharacterBody3D

# Physics attributes
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var input_dir = Input.get_vector("left", "right", "up", "down")
var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

# Other variables
var debugMode:bool = false
var camera_node : Camera3D = null
var feather_pivot: Node3D = null

func _ready():
	camera_node = $playerCam
	feather_pivot = $featherPivot

func _input(event):
	input_dir = Input.get_vector("left", "right", "up", "down")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if event is InputEventMouseMotion:
		rotateFeatherPivot()
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _physics_process(delta):
	if not is_on_floor(): # Add the gravity.
		velocity.y -= gravity * delta
	handleWalking()
	move_and_slide()
	
func rotateFeatherPivot():
		var mousePos:Vector2 = get_viewport().get_mouse_position()
		var mouseAngle = atan2(mousePos.y, mousePos.x) # convert to rotation angle about player
		var player_global_position : Vector3 = feather_pivot.global_transform.origin
		# Project the 3D position to viewport coordinates using the camera
		var player_viewport_position : Vector2 = camera_node.unproject_position(player_global_position)
		var mouse_normal = (mousePos - player_viewport_position).normalized() # Use the player_viewport_position is needed
		var mouse_angle = (atan2(mouse_normal.y, mouse_normal.x))
		feather_pivot.rotation.z = -(mouse_angle) + 30
		if debugMode:
			print("MousePos: ", mousePos, "\n", "MouseAngle: ", mouseAngle, "\n")
			print("Player Position in Viewport Coordinates:", player_viewport_position)
			print("Mouse normal:", mouse_normal)
			print("Mouse angle: ", mouse_angle)

func handleWalking():
	if direction:
		velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED # negate Z velocity / lock movement to X,Y plane
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
