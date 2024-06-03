extends Node

@onready var mosketeerScene : PackedScene = preload("res://Musketeer/Musketeer.tscn")
@onready var timer : Timer = $Timer
@export var laneAttack:String

##TODO: Refactorizar código después de hacer ataque melé

func _ready():
	timer.timeout.connect(StartWave)
	timer.start()

var mosketeerInstance: CharacterBody3D
func StartWave():
	mosketeerInstance = mosketeerScene.instantiate()
	mosketeerInstance.laneAttack = laneAttack
	add_child(mosketeerInstance)
	timer.start()
