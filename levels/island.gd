extends Node3D

@onready var prop_crate_1: MeshInstance3D = $island/Prop_Crate_1

func delete_box1():
	if prop_crate_1:
		prop_crate_1.queue_free()
