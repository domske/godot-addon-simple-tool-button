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
    var button = Button.new()
    button.set("theme_override_styles/normal", new_style(Color(0.5, 0.5, 0.5, 0.1)))

    match(type):
      # Use bool setter as button. This buttons also works without this addon.
      TYPE_BOOL:
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

      # Use dictonary to pass data to this addon. This button only works with this addon.
      TYPE_DICTIONARY:
        var value: Dictionary = object.get(name)
        button.text = name.right(-4).capitalize()

        if value.has("text"):
          button.text = value.get("text")

        if value.has("click"):
          button.pressed.connect(value.get("click"))

        if value.has("icon"):
          var icon_value = value.get("icon")
          var icon: Texture2D
          if icon_value.begins_with("res://"):
            icon = load(value.get("icon"))
          else:
            icon = EditorInterface.get_editor_theme().get_icon(icon_value, "EditorIcons")
          if icon:
            button.icon = icon

        if value.has("color"):
          var color_value: Variant = value.get("color")
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

    add_custom_control(button)
    return true
  return false

func new_style(color: Color, alpha = color.a) -> StyleBox:
  var style_box := StyleBoxFlat.new()
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
