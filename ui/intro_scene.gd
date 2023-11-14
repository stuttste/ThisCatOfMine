extends Control

signal screen_closed()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			screen_closed.emit()
			queue_free()
			
func set_text(text):
	$Panel/MainText.text = text
