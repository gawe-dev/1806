extends CharacterBody3D

@onready var shoot_ray:RayCast3D = $CollisionShape3D/ShootRay
@onready var climb_ray:RayCast3D = $CollisionShape3D/ClimbRay
@onready var timer : Timer = $Timer

@export var laneAttack : String

var flags:Array[Node3D]
var barricades:Array[Node3D]
var target:Node3D
var drops:Node
func _ready():
	##Obtener todas las banderas del spawn de esta instancia
	for node in get_parent().find_children("Flag*", "Node3D",false):
		flags.push_back(node)
	
	##Obtener todas las barricadas de la linea sugerida por el spawn
	for node in get_tree().current_scene.find_child(laneAttack).get_children(false):
		barricades.push_back(node)
	
	##Obtener player para targetear
	target = get_tree().current_scene.get_node("%Player")
	drops = get_tree().current_scene.get_node("%Drops")
	
	##Conectar timer con callback
	timer.timeout.connect(ShootOrReload)

var delta : float
func _physics_process(_delta):
	delta = _delta
	ApplyGravity()
	ForwardMode()
	RotateToward()
	ClimbStairs()
	PrepareAiming()
	move_and_slide()

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
func ApplyGravity():
	velocity.y -= gravity * delta

var speed : float
var forward_mode := "walk"
func ForwardMode():
	velocity.x = global_basis.z.x * speed
	velocity.z = global_basis.z.z * speed
	if forward_mode.contains("walk"):
		speed = 1
	if forward_mode.contains("stop"):
		speed = 0

var current_flag = 0
func RotateToward():
	#si mi padre es cover
	if get_parent().name.contains("Cover"):
		#si estoy lejos de cover
		if (global_position - get_parent().global_position).length() > .5:
			look_at(get_parent().global_position, Vector3.UP,true)
			rotation.x = 0
			rotation.z = 0
		else:
			forward_mode = "stop"
	else: #si mi padre no es cover
		#si la bandera tiene hijos
		if flags[current_flag].find_children("Cover*").size() != 0:
			#recorrer cada hijo (cover)
			for cover in flags[current_flag].find_children("Cover*"):
				#si cover no tiene un hijo
				if cover.get_child_count() == 0:
					#emparentar esta instancia a cover
					reparent(cover)
			#si para este punto no tiene de padre a cover
			if not get_parent().name.contains("Cover"):
				NextFlagOrDie()
		else: #si la bandera no tiene hijos
			NextFlagOrDie()
			look_at(flags[current_flag].global_position, Vector3.UP,true)

func NextFlagOrDie():
	if (global_position - flags[current_flag].global_position).length() < 1:
		if current_flag + 1 < flags.size():
			current_flag += 1
		else:
			queue_free()

func ClimbStairs():
	if climb_ray.is_colliding() and climb_ray.get_collider().is_in_group("Stair"):
		velocity.y = 2

var current_barricade := 0
var reloading := false
func PrepareAiming():
	if (global_position - target.global_position).length() < (shoot_ray.target_position.z - 5):
		shoot_ray.look_at(target.global_position, Vector3.UP, true)
		if not reloading:
			velocity.x = 0
			velocity.z = 0
			AimAndShoot()
	elif (global_position - barricades[current_barricade].global_position).length() < (shoot_ray.target_position.z):
		shoot_ray.look_at(barricades[current_barricade].global_position, Vector3.UP, true)
		if not reloading:
			AimAndShoot()
	elif shoot_ray.rotation.x != 0 and shoot_ray.rotation.y != 0 and shoot_ray.rotation.z != 0:
			shoot_ray.rotation.x = 0
			shoot_ray.rotation.y = 0
			shoot_ray.rotation.z = 0

var can_shoot := true
func AimAndShoot():
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
		shoot_ray.enabled = false
		can_shoot = false
		reloading = true
		timer.wait_time = 10
		timer.start()
	else:
		shoot_ray.enabled = true
		timer.wait_time = 5
		can_shoot = true
		reloading = false

var health := 1
func GetDamage(damage:int):
	if health <= 0:
		#dropear
		drops.createDrop(global_position)
		queue_free()





