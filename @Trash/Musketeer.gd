extends CharacterBody3D

@onready var shoot_ray:RayCast3D = $CollisionShape3D/ShootRay
@onready var climb_ray:RayCast3D = $CollisionShape3D/ClimbRay
@onready var timer : Timer = $Timer

@export var laneAttack : String

var target:Node3D
var flags:Array[Node3D]
var barricades:Array[Node3D]
func _ready():
	target = get_tree().current_scene.get_node("%Player")
	timer.timeout.connect(ShootOrReload)
	##Obtener todas las banderas del spawn de esta instancia
	for node in get_parent().find_children("Flag*", "Node3D",false):
		flags.push_back(node)
	##Obtener todas las barricadas de la linea sugerida por el spawn
	for node in get_tree().current_scene.find_child(laneAttack).get_children(false):
		barricades.push_back(node)

var delta : float
func _physics_process(_delta):
	delta = _delta
	ApplyGravity()
	WalkForward()
	RotateToCurrentFlag()
	ClimbWalls()
	StopAndPrepare()
	move_and_slide()
	FreeQueue()

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func ApplyGravity():
	velocity.y -= gravity * delta

var speed := 3.0
func WalkForward():
	velocity.x = global_basis.z.x * speed
	velocity.z = global_basis.z.z * speed

var current_flag = 0
func RotateToCurrentFlag():
	look_at(flags[current_flag].global_position, Vector3.UP,true)
	rotation.x = 0
	rotation.z = 0

func FreeQueue():
	if global_position.y < -15:
		queue_free()
	if (global_position - flags[current_flag].global_position).length() < .5:
		if current_flag + 1 < flags.size():
			current_flag += 1
		else:
			queue_free()

func ClimbWalls():
	if climb_ray.is_colliding():
		if climb_ray.get_collider().is_in_group("Stair"):
			velocity.y = 2

var reloading := false
var can_shoot := true
var current_barricade := 0
func StopAndPrepare():
	if (global_position - target.global_position).length() < (shoot_ray.target_position.z - 5):
		shoot_ray.look_at(target.global_position, Vector3.UP, true)
		if not reloading:
			velocity.x = 0
			velocity.z = 0
			AimAndShoot()
	elif (global_position - barricades[current_barricade].global_position).length() < (shoot_ray.target_position.z):
		shoot_ray.look_at(barricades[current_barricade].global_position, Vector3.UP, true)
		if speed > .1:
			speed -= .004
		else:
			speed = .1
		##POSICIONARSE
		if not reloading:
			AimAndShoot()
	elif shoot_ray.rotation.x != 0 and shoot_ray.rotation.y != 0 and shoot_ray.rotation.z != 0:
			shoot_ray.rotation.x = 0
			shoot_ray.rotation.y = 0
			shoot_ray.rotation.z = 0
			is_aiming = false

var is_aiming := false
func AimAndShoot():
	is_aiming = true
	if can_shoot:
		can_shoot = false
		timer.start()

func ShootOrReload():
	if not reloading:
		print("Animación de disparo")
		if (
			shoot_ray.is_colliding()
		and shoot_ray.get_collider().has_method("GetDamage")
		):
			shoot_ray.get_collider().GetDamage(1)
			print("sonido de disparé y le di")
		else:
			print("sonido disparé y no le di")
		can_shoot = false
		reloading = true
		timer.start()
	else:
		can_shoot = true
		reloading = false
