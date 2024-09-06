extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
  return object is Node

func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
  if name.begins_with("btn_"):
    var button = Button.new()
    button.text = name.right(-4).capitalize()
    button.pressed.connect(func (): object[name] = true)
    add_custom_control(button)
    return true
  return false
