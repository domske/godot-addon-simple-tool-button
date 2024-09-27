extends EditorInspectorPlugin

# NOTE Changes may require a restart (reload addon).

# NOTE Advanced buttons variable names must be updated when value changed. Or use get without set.

# See available EditorIcons:
# - print(EditorInterface.get_editor_theme().get_icon_list("EditorIcons"))
# - https://github.com/godotengine/godot/tree/master/editor/icons
# - Autocomplete (CTRL + SPACE) should also show the icon in editor.

var colors := {
	"danger": Color.html("#da1d0b"),
	"warning": Color.html("#e5a11a"),
	"success": Color.html("#22c358"),
	"info": Color.html("#1a5ee5"),
}

# Advanced buttons only.
var known_buttons: Dictionary = {}
var current_node: Object

func _can_handle(object: Object) -> bool:
	current_node = object
	known_buttons.clear()
	return object is Object

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	if name.begins_with("btn_"):
		match(type):
			# Use bool setter as button. This buttons also works without this addon.
			TYPE_BOOL:
				var button = create_button()
				var parts = name.split("_")
				var button_text = "_".join(parts.slice(1, parts.size()))

				if parts.size() > 2:
					var color_name = parts[1]
					if colors.has(color_name):
						var color: Color = colors.get(color_name)
						button_text = "_".join(parts.slice(2, parts.size()))
						set_color(button, color)

				button.text = button_text.capitalize()
				button.pressed.connect(func (): object[name] = true)

				add_custom_control(button)
				return true

			# Use dictonary to pass data to this addon. This button only works with this addon.
			TYPE_ARRAY, TYPE_DICTIONARY:
				var button_list: Array
				if type == TYPE_DICTIONARY:
					var dict: Dictionary = object.get(name)
					button_list = [dict]
				else:
					button_list = object.get(name)

				var buttons_size := button_list.size()

				var container := HBoxContainer.new()
				container.alignment = BoxContainer.ALIGNMENT_CENTER;
				known_buttons[name] = container

				for button_index in range(buttons_size):
					var button_item: Dictionary = button_list[button_index]
					var button = create_button()
					button.text = name.right(-4).capitalize()
					if buttons_size > 1:
						button.text += " " + str(button_index + 1)
					update_button(button, button_item, container)
					container.add_child(button)

				add_custom_control(container)
				return true

	return false

func create_button() -> Button:
	var button := Button.new()
	button.set("theme_override_styles/normal", new_style(Color(0.5, 0.5, 0.5, 0.1)))
	return button

func new_style(color: Color, alpha = color.a) -> StyleBox:
	var style_box := StyleBoxFlat.new()
	style_box.set_corner_radius_all(5)
	if alpha:
		color.a = alpha
	style_box.bg_color = color
	return style_box

func set_color(button: Button, color: Color) -> void:
	button.set("theme_override_styles/normal", new_style(color, 0.2))
	button.set("theme_override_styles/hover", new_style(color, 0.3))
	button.set("theme_override_styles/hover_pressed", new_style(color, 0.4))
	button.set("theme_override_styles/pressed", new_style(color, 0.4))

	button.set("theme_override_colors/font_color", color)
	button.set("theme_override_colors/font_hover_color", color)
	button.set("theme_override_colors/font_hover_color", color)
	button.set("theme_override_colors/font_pressed_color", color.lightened(0.3))
	button.set("theme_override_colors/font_focus_color", color)

func update_button(button: Button, props: Dictionary, container: HBoxContainer) -> void:
	if props.has("text"):
		button.text = props.get("text")

	if props.has("click"):
		var callable := Callable(props.get("click"))
		button.pressed.connect(func():
			var trigger_refresh = callable.call()
			if trigger_refresh:
				refresh()
		)

	if props.has("icon"):
		var icon_value = props.get("icon")
		var icon: Texture2D
		if icon_value.begins_with("res://"):
			icon = load(props.get("icon"))
		else:
			icon = EditorInterface.get_editor_theme().get_icon(icon_value, "EditorIcons")
		if icon:
			button.icon = icon

	if props.has("color"):
		var color_value: Variant = props.get("color")
		var color: Color
		if typeof(color_value) == TYPE_COLOR:
			color = color_value
		elif typeof(color_value) == TYPE_STRING:
			if color_value.begins_with('#'):
				color = Color.html(color_value)
			elif colors.has(color_value):
				color = colors.get(color_value)
		if color:
			set_color(button, color)

	if props.has("fill"):
		if props.get("fill"):
			button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		else:
			button.size_flags_horizontal = 0

	if props.has("align"):
		var align = props.get("align")
		match(align):
			"begin": container.alignment = BoxContainer.ALIGNMENT_BEGIN;
			"center": container.alignment = BoxContainer.ALIGNMENT_CENTER;
			"end": container.alignment = BoxContainer.ALIGNMENT_END;

func refresh():
	# Is there no official way to refresh inspector?
	for property_name in known_buttons:
		var container: HBoxContainer = known_buttons[property_name]
		var property_value = current_node.get(property_name)
		if typeof(property_value) == TYPE_DICTIONARY:
			property_value = [property_value]

		for i in property_value.size():
			var props: Dictionary = property_value[i]
			props.erase("click")
			update_button(container.get_child(i), props, container)
