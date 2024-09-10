extends EditorInspectorPlugin

# NOTE Changes may require a restart (reload addon).

# NOTE Advanced buttons variable names must be updated when Dictionary changed.

# See available EditorIcons:
# print(EditorInterface.get_editor_theme().get_icon_list("EditorIcons"))
# https://github.com/godotengine/godot/tree/master/editor/icons

var colors := {
  "danger": Color.html("#da1d0b"),
  "warning": Color.html("#e5a11a"),
  "success": Color.html("#22c358"),
  "info": Color.html("#1a5ee5"),
}

func _can_handle(object: Object) -> bool:
  return object is Node

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

        for button_index in range(buttons_size):
          var button_item: Dictionary = button_list[button_index]
          var button = create_button()

          button.text = name.right(-4).capitalize()
          if buttons_size > 1:
            button.text += " " + str(button_index + 1)

          if button_item.has("text"):
            button.text = button_item.get("text")

          if button_item.has("click"):
            button.pressed.connect(button_item.get("click"))

          if button_item.has("icon"):
            var icon_value = button_item.get("icon")
            var icon: Texture2D
            if icon_value.begins_with("res://"):
              icon = load(button_item.get("icon"))
            else:
              icon = EditorInterface.get_editor_theme().get_icon(icon_value, "EditorIcons")
            if icon:
              button.icon = icon

          if button_item.has("color"):
            var color_value: Variant = button_item.get("color")
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

          if button_item.has("fill") and button_item.get("fill"):
            button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL

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
