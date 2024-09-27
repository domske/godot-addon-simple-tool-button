@tool
extends Label3D

var click_count := 0
var playing = false;

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
			"align": "end",
			"text": "Pause" if playing else "Play",
			"icon": "Pause" if playing else "Play",
			"color": "warning" if playing else "success",
			"click": func():
				playing = !playing
				return true,
		},
		{
			"text": "Stop",
			"icon": "Stop",
			"color": "danger",
			"click": func():
				playing = false
				return true,
		}
	]


var align = "begin"
@export var btn_align: Dictionary:
	get: return {
		"icon": "HBoxContainer",
		"text": "Align " + align,
		"align": align,
		"click": func():
			if align == "end": align = "begin"
			elif align == "center": align = "end"
			elif align == "begin": align = "center"
			return true
	}

var fill = false
@export var btn_fill: Array:
	get: return [
		{
			"icon": "res://icons/x-contract.svg" if fill else "res://icons/x-expand.svg",
			"text": "Contract" if fill else "Expand",
			"fill": fill,
			"click": func():
				fill = !fill
				return true,
		},
		{
			"text": "Another",
		}
	]


@export var btn_count: Dictionary:
	get: return {
		"text": "Count: " + str(click_count),
		"click": func():
			update()
			return { "text": "Count: " + str(click_count) }
	}

@export var btn_compat: Dictionary:
	get: return {
		"icon": "Callable",
		"click": func(): prints("Button clicked!", randi())
	}

@export_category("Some tests")

@export var my_curve: Curve

func update():
	click_count += 1
	text = "Button click count: " + str(click_count)
	print(text)
