extends EditorInspectorPlugin

# NOTE Changes may require a restart (reload addon).

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
    var parts = name.split("_")
    var button_text = "_".join(parts.slice(1, parts.size()))
    button.set("theme_override_styles/normal", new_style(Color(0.5, 0.5, 0.5, 0.1)))

    if parts.size() > 2:
      var color_name = parts[1]
      if colors.has(color_name):
        var color: Color = colors.get(color_name)
        button_text = "_".join(parts.slice(2, parts.size()))

        button.set("theme_override_styles/normal", new_style(color, 0.2))
        button.set("theme_override_styles/hover", new_style(color, 0.3))
        button.set("theme_override_styles/hover_pressed", new_style(color, 0.4))
        button.set("theme_override_styles/pressed", new_style(color, 0.4))

        button.set("theme_override_colors/font_color", color)
        button.set("theme_override_colors/font_hover_color", color)
        button.set("theme_override_colors/font_hover_color", color)
        button.set("theme_override_colors/font_pressed_color", color.lightened(0.3))
        button.set("theme_override_colors/font_focus_color", color)

    button.text = button_text.capitalize()
    button.pressed.connect(func (): object[name] = true)
    add_custom_control(button)
    return true
  return false

func new_style(color: Color, alpha = color.a) -> StyleBox:
  var style_box := StyleBoxFlat.new()
  if alpha:
    color.a = alpha
  style_box.bg_color = color
  return style_box
