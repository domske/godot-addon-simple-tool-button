@tool
extends Label3D

var click_count := 0

@export_range(0.0, 100.0) var value := 42.0
@export var check_me := false

@export var btn_update: bool:
  set(v): update()

@export var btn_danger_delete: bool:
  set(v): update()

@export var btn_warning_try_it: bool:
  set(v): update()

@export var btn_success_confirm: bool:
  set(v): update()

@export var btn_info_info: bool:
  set(v): update()

func update():
  click_count += 1
  text = "Button click count: " + str(click_count)
  print(text)
