extends Node

@onready var mosketeerScene : PackedScene = preload("res://Musketeer/Musketeer.tscn")
@onready var timer : Timer = $Timer

func _ready():
	timer.timeout.connect(StartWave)
	timer.start()

var mosketeerInstance: CharacterBody3D
func StartWave():
	mosketeerInstance = mosketeerScene.instantiate()
	
	add_child(mosketeerInstance)
	timer.start()
