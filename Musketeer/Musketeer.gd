extends CharacterBody3D

var flags:Array[Node3D]

func _ready():
	##Obtener todas las banderas del spawn de esta instancia
	for node in get_parent().find_children("Flag*", "Node3D",false):
		flags.push_back(node)

var delta : float
func _physics_process(_delta):
	delta = _delta
	ForwardMode()
	RotateToward()
	
	move_and_slide()

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
			##Si para este punto no tiene de padre a cover
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















