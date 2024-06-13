extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack

@onready var Animation_Player:AnimationPlayer = $FPSRig/AnimationPlayer
@onready var Bullet_Point:Node3D = $FPSRig/BulletPoint

var Current_Weapon:Weapon_Resource = null
var Weapon_Stack = []
var Weapon_Indicator = 0
var Next_Weapon: String
var Weapon_List = {}

@export var _weapon_resources: Array[Weapon_Resource]

@export var Start_Weapons: Array[String]

enum {NULL, HITSCAN, PROJECTILE, MELE}

func _ready():
	Initialize(Start_Weapons)

func _input(event):
	if event.is_action_pressed("WeaponUp"):
		Weapon_Indicator = min(Weapon_Indicator + 1, Weapon_Stack.size()-1)
		exit(Weapon_Stack[Weapon_Indicator])
	if event.is_action_pressed("WeaponDown"):
		Weapon_Indicator = max(Weapon_Indicator - 1,0)
		exit(Weapon_Stack[Weapon_Indicator])
	if event.is_action_pressed("Shoot") and Input.is_action_pressed("zoom"):
		shoot()
	if event.is_action_pressed("Reload"):
		reload()

func Initialize(_start_weapons: Array):
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_Name] = weapon
	for i in _start_weapons:
		Weapon_Stack.push_back(i)
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	emit_signal("Update_Weapon_Stack",Weapon_Stack)
	enter()

func enter():
	Animation_Player.queue(Current_Weapon.Activate_Anim)
	emit_signal("Weapon_Changed", Current_Weapon.Weapon_Name)
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])

func exit(_next_weapon: String):
	if _next_weapon != Current_Weapon.Weapon_Name:
		if Animation_Player.current_animation != Current_Weapon.Deactivate_Anim:
			Animation_Player.play(Current_Weapon.Deactivate_Anim)
			Next_Weapon = _next_weapon

func Change_Weapon(weapon_name: String):
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Deactivate_Anim:
		Change_Weapon(Next_Weapon)
	
	if anim_name == Current_Weapon.Shoot_Anim && Current_Weapon.Auto_Fire == true:
		if Input.is_action_pressed("Shoot"):
			shoot()

func shoot():
	if Current_Weapon.Current_Ammo != 0:
		if !Animation_Player.is_playing():
			Animation_Player.play(Current_Weapon.Shoot_Anim)
			Current_Weapon.Current_Ammo -= 1
			emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
			var Camera_Collision = Get_Camera_Collision()
			match Current_Weapon.Type:
				NULL:
					print("Weapon Type Not Chosem")
				HITSCAN:
					Hit_Scan_Collision(Camera_Collision)
				MELE:
					pass
	else:
		reload()

func reload():
	if Current_Weapon.Reserve_Ammo == 0:
		return
	if Current_Weapon.Current_Ammo == Current_Weapon.Magazine:
		return
	elif !Animation_Player.is_playing():
		Animation_Player.play(Current_Weapon.Reload_Anim)
		var Reload_Amount = min(Current_Weapon.Magazine - Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo)
		Current_Weapon.Current_Ammo = Current_Weapon.Current_Ammo + Reload_Amount
		Current_Weapon.Reserve_Ammo = Current_Weapon.Reserve_Ammo - Reload_Amount
		emit_signal("Update_Ammo",[Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	else:
		Animation_Player.play(Current_Weapon.Shoot_Anim) #se supone que acá va "disparo sin balas animation"

func Get_Camera_Collision():
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().size
	var Ray_Origin = camera.project_ray_origin(viewport/2)
	var Ray_End = Ray_Origin + camera.project_ray_normal(viewport/2)*Current_Weapon.Weapon_Range
	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin, Ray_End)
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	if not Intersection.is_empty():
		var Col_Point = Intersection.position
		return Col_Point
	else:
		return Ray_End

func Hit_Scan_Collision(Collision_Point):
	var Bullet_Direction = (Collision_Point - Bullet_Point.global_transform.origin).normalized()
	var New_Interaction = PhysicsRayQueryParameters3D.create(Bullet_Point.global_transform.origin,Collision_Point+Bullet_Direction*2)
	var Bullet_Collision = get_world_3d().direct_space_state.intersect_ray(New_Interaction)
	if Bullet_Collision:
		Hit_Scan_Damage(Bullet_Collision["collider"])

func Hit_Scan_Damage(Collider):
	print("DISPARÉ")
	if Collider.has_method("Hit_Successful"):
		print("LE DI")
		Collider.Hit_Successful(Current_Weapon.Damage)


func _on_sword_hit_body_entered(body):
	if body.has_method("Hit_Successful"):
		body.Hit_Successful(Current_Weapon.Damage)

func AddAmmo(ammoType:String):
	Weapon_List[ammoType].Reserve_Ammo += 1
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
