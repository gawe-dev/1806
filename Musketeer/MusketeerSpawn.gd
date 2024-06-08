extends Node

@onready var mosketeerScene : PackedScene = preload("res://Musketeer/Musketeer.tscn")
@onready var timer : Timer = $Timer

@export var laneAttack:String

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		StartWave()

var mosketeerInstance: CharacterBody3D
func StartWave():
	mosketeerInstance = mosketeerScene.instantiate()
	mosketeerInstance.laneAttack = "Mid"
	add_child(mosketeerInstance)
	timer.start()
