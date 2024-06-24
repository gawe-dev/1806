extends Node

@onready var arquebusierScene : PackedScene = preload("res://Arquebusier/Arquebusier.tscn")
@onready var timer : Timer = $Timer

@export var laneAttack:String

func _ready():
	timer.timeout.connect(StartWave)
	StartWave()

var arquebusierInstance: CharacterBody3D
func StartWave():
	arquebusierInstance = arquebusierScene.instantiate()
	arquebusierInstance.laneAttack = laneAttack
	add_child(arquebusierInstance)
	timer.start()
