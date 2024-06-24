extends Node

@onready var mosketeerScene : PackedScene = preload("res://Musketeer/Musketeer.tscn")
@onready var timer : Timer = $Timer

@export var laneAttack:String

func _ready():
	timer.timeout.connect(StartWave)
	StartWave()

var mosketeerInstance: CharacterBody3D
func StartWave():
	mosketeerInstance = mosketeerScene.instantiate()
	mosketeerInstance.laneAttack = "Mid"
	add_child(mosketeerInstance)
	timer.start()
