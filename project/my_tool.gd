@tool
extends MeshInstance3D

@export_range(0.0, 100.0) var value := 42.0
@export var check_me := false

@export var btn_update: bool:
  set(v): update("Test")

func update(text: String):
  prints("Button pressed:", text, check_me)
