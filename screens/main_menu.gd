extends Control

@onready var intro_scene = preload("res://ui/intro_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_pressed():
	get_tree().quit()


func _on_new_game_pressed():
	GameManager.initialize_new_game()
	get_tree().change_scene_to_file("res://screens/mission_board.tscn")


func _on_load_game_pressed():
	if GameManager.load_game():
		get_tree().change_scene_to_file("res://screens/mission_board.tscn")
	else:
		var intro_scene_inst = intro_scene.instantiate()
		intro_scene_inst.position = self.position
		intro_scene_inst.set_text("Game already completed. Please start a New Game.")
		add_child(intro_scene_inst)
	
	
