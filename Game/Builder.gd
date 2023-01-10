extends Node2D

export(PackedScene) var turret : PackedScene
var hold : Node


func _process(_delta):
	if Input.is_action_pressed("place_turret") and hold != null:
		place_build()

func start_build():
	var instantiated : Node2D = turret.instance()
	instantiated.set_process(false)
	instantiated.set_physics_process(false)
	hold = instantiated
	add_child(instantiated)

func place_build():
	var new_parent = get_tree().get_nodes_in_group("turrets")[0]
	var new_position = global_position;
	remove_child(hold);
	new_parent.add_child(hold)
	hold.global_position = new_position
	hold = null
