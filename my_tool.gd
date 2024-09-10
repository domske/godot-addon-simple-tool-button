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

@export_category("Advanced buttons")

@export var btn_advanced: Array:
  get: return [{
    "icon": "res://icons/check.svg",
    "color": "#FF00FF",
    "text": "Custom Icon",
    "click": func(): update(),
  }]

@export var btn_custom_image: Array:
  get: return [{
    "icon": "res://icons/image.png",
    "click": func(): update(),
  }]

@export var btn_editor_icon: Array:
  get: return [{
    "icon": "Button",
    "fill": true,
    "click": func(): update(),
  }]

@export var btn_mutiple_buttons: Array:
  get: return [
    {
      "text": "Play",
      "icon": "Play",
      "color": "success",
      "click": func(): update(),
    },
    {
      "text": "Stop",
      "icon": "Stop",
      "color": "danger",
      "click": func(): update(),
    }
  ]

@export var btn_compat: Dictionary:
  get: return {
    "icon": "Callable",
    "click": func(): update(),
  }

func update():
  click_count += 1
  text = "Button click count: " + str(click_count)
  print(text)
