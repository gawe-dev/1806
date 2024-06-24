extends CharacterBody3D

@onready var twist_pivot : Node3D = $TwistPivot
@onready var pitch_pivot : Node3D = $TwistPivot/PitchPivot

@onready var rayHook : RayCast3D = $TwistPivot/PitchPivot/Camera3D/RayCast3D
@onready var rayGetDrops : RayCast3D = $MeshInstance3D/GetDrops
@onready var camera : Camera3D = $TwistPivot/PitchPivot/Camera3D
@onready var model : MeshInstance3D = $MeshInstance3D

var delta:float
func _physics_process(_delta):
	delta = _delta
	GravityManagement()
	
	RotateCamara()
	InputHideMouse()
	
	InputHook()
	InputMovement()
	InputJump()
	
	InputCameraMode()
	
	GetDrops()
	move_and_slide()
	


#region New Code Region
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var gravity_state : String = "Falling"
var hook_position : Vector3
func GravityManagement():
	if gravity_state == "Falling":
		velocity.y -= gravity * delta
	
	if gravity_state == "Hooking":
		global_position = global_position.move_toward(hook_position,.2)
		if (global_position - hook_position).length() < .095:
			gravity_state = "Falling"
#endregion


#region New Code Region
var jump_velocity := 3.5
func InputJump():
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = jump_velocity
		if gravity_state == "Hooking":
			gravity_state = "Falling"
			velocity.y = jump_velocity * 2.5
#endregion


#region New Code Region
func InputHook():
	if Input.is_action_just_pressed("hook"):
		if rayHook.is_colliding():
			gravity_state = "Hooking"
			hook_position = rayHook.get_collision_point()
		else:
			gravity_state = "Falling"
#endregion


#region New Code Region
var input_dir : Vector2
var direction : Vector3
var speed := 5.0
func InputMovement():
	input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = (twist_pivot.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
#endregion


#region New Code Region
func InputHideMouse():
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
#endregion


#region CameraFunctions
var mouse_sensitivity := 0.001
var twist_input := 0.001
var pitch_input := 0.001
func RotateCamara():
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, -1, .7)
	
	twist_input = 0.0
	pitch_input = 0.0


func _unhandled_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity


var apuntando:bool
func InputCameraMode():
	apuntando = Input.is_action_pressed("zoom")
	
	if not apuntando:
		if input_dir != Vector2.ZERO:
			model.rotation.y = lerp_angle(model.rotation.y,atan2(-direction.x,-direction.z),.3)
			
		if camera.position.z < 3.9:
			speed = 5.0
			camera.position = lerp(camera.position,Vector3(0,2.5,4),.1)
	
	if apuntando:
		model.rotation.y = lerp_angle(model.rotation.y,twist_pivot.rotation.y,.3)
		if camera.position.z > 1.7:
			speed = 2.0
			camera.position = lerp(camera.position,Vector3(1.3,2,1.6),.1)
#endregion


func GetDrops():
	if rayGetDrops.is_colliding():
		if rayGetDrops.get_collider().name.contains("DropMusket"):
			$MeshInstance3D/WeaponsManager.AddAmmo("GunMusket")
		if rayGetDrops.get_collider().name.contains("DropArquebus"):
			$MeshInstance3D/WeaponsManager.AddAmmo("GunArquebus")
		rayGetDrops.get_collider().queue_free()


var health := 5
func GetDamage(damage:int):
	health -= damage
	if health <= 0:
		#dropear
		position.x=-9
		position.y=3
		position.z=25
		health = 5

