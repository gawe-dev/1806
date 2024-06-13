extends Node

@onready var dropMusketScene : PackedScene = preload("res://Drops/DropMusket.tscn")

var rng := RandomNumberGenerator.new()
var rngi:int
var newDropMusket:Node3D
func createDrop(global_position:Vector3):
	rngi = rng.randi_range(1,2)
	
	if rngi == 1:
		newDropMusket = dropMusketScene.instantiate()
		add_child(newDropMusket)
		newDropMusket.global_position = global_position
