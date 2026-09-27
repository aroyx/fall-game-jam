extends Node3D

@onready var box_1: MeshInstance3D = $island/Prop_Crate_1
@onready var box_2: MeshInstance3D = $island/Prop_Crate_12
@onready var treasure_chest_1: MeshInstance3D = $island/Beach_Prop_Treasure_Chest2
@onready var treasure_chest_2: MeshInstance3D = $island/Beach_Prop_Treasure_Chest

func delete_box_1():
	if box_1:
		box_1.queue_free()

func delete_box_2():
	if box_2:
		box_2.queue_free()

func delete_treasure_chest_1():
	if treasure_chest_1:
		treasure_chest_1.queue_free()

func delete_treasure_chest_2():
	if treasure_chest_2:
		treasure_chest_2.queue_free()
