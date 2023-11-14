extends Node2D

@onready var help_screen = preload("res://ui/help_screen.tscn")
@onready var mission_result_screen = preload("res://ui/mission_result_screen.tscn")
@onready var intro_scene = preload("res://ui/intro_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if GameManager.new_game:
		var intro_scene_inst = intro_scene.instantiate()
		add_child(intro_scene_inst)
		GameManager.new_game = false
		
	GameManager.connect("game_won_sig", Callable(self, "game_won"))
	GameManager.connect("game_lost_sig", Callable(self, "game_lost"))
	
	var cat_nodes = get_tree().get_nodes_in_group("Cat")
	for cat in cat_nodes:
		if cat.cat_name in GameManager.load_game_data:
			var cat_dict = GameManager.load_game_data[cat.cat_name]
			cat.grit = cat_dict["grit"]
			cat.dexterity = cat_dict["dexterity"]
			cat.alpha_rating = cat_dict["alpha_rating"]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.felix_recruited: $Cats/Felix.show()
	else: $Cats/Felix.hide()
	
	if GameManager.raya_recruited: $Cats/Raya.show()
	else: $Cats/Raya.hide()
	
	apply_shortage_indicator()

func _on_begin_missions_pressed():
	var compiled_mission_results = {}
	
	for mission in get_tree().get_nodes_in_group("Mission"):
		if mission.has_method("go_on_mission"):
			mission.go_on_mission()
			if mission.cat_assigned: compiled_mission_results[mission.location_name] = mission.most_recent_results
		if mission.has_method("unassign_cat_from_mission"):
			mission.unassign_cat_from_mission()
			
	for cat in get_tree().get_nodes_in_group("Cat"):
		if cat.has_method("unassign_cat"):
			cat.unassign_cat()
	
	var mission_result_screen_inst = mission_result_screen.instantiate()
	mission_result_screen_inst.connect("screen_closed", Callable(self, "_on_result_screen_closed"))
	if mission_result_screen_inst.has_method("render_results"):
		mission_result_screen_inst.render_results(compiled_mission_results)
	add_child(mission_result_screen_inst)
	
	GameManager.progress_day()
	GameManager.save_game()

func _on_result_screen_closed():
	if GameManager.day == 2 and not GameManager.felix_recruited: trigger_felix_recruit()
	elif GameManager.day == 3 and not GameManager.raya_recruited: trigger_raya_recruit()

func _on_help_pressed():
	var help_screen_inst = help_screen.instantiate()
	help_screen_inst.global_position = self.global_position
	self.add_child(help_screen_inst)
	
func trigger_felix_recruit():
	var recruit_text = """
	As the morning light illuminates Milo's hovel, he spots a black cat rummaging through his collected treasures.
	
	Milo befriends the cat and promises him many treasures if he agrees to join them.
	
	Felix recruited!
	"""
	
	var intro_scene_inst = intro_scene.instantiate()
	intro_scene_inst.set_text(recruit_text)
	add_child(intro_scene_inst)
	GameManager.felix_recruited = true
	
func trigger_raya_recruit():
	var recruit_text = """
	Milo hears rustling in the cardboard littering the group's home.
	
	A small rat suddenly scurries from out beneath the pile.
	
	Before Milo has a chance to take in what he sees, a lean spotted grey cat swoops down onto the rat and makes short work of it.
	
	Milo makes quick friends with the newcomer and she agrees to join them, with the promise of as much food as she can eat of course.
	
	Raya recruited!
	"""
	
	var intro_scene_inst = intro_scene.instantiate()
	intro_scene_inst.set_text(recruit_text)
	add_child(intro_scene_inst)
	GameManager.raya_recruited = true

func game_won():
	var intro_scene_inst = intro_scene.instantiate()
	intro_scene_inst.set_text("Milo freed his family!")
	intro_scene_inst.connect("screen_closed", Callable(self, "return_to_menu"))
	add_child(intro_scene_inst)
	GameManager.game_completed = true

func game_lost(reason):
	var intro_scene_inst = intro_scene.instantiate()
	intro_scene_inst.set_text(reason)
	intro_scene_inst.connect("screen_closed", Callable(self, "return_to_menu"))
	add_child(intro_scene_inst)
	GameManager.game_completed = true
	
func return_to_menu():
	if GameManager.game_completed: get_tree().change_scene_to_file("res://screens/main_menu.tscn")
	
func apply_shortage_indicator():
	for resource_type in GameManager.RESOURCE_TYPES:
		var needed_amt = GameManager.calculate_resource_need(resource_type)
		var resource_amt = GameManager.get_resource_amt_by_string(resource_type) 
		if resource_amt < needed_amt:
			get_node("UI/"+ resource_type.to_pascal_case() +"Label").add_theme_color_override("font_color", Color.INDIAN_RED)
		else:
			if get_node("UI/"+ resource_type.to_pascal_case() +"Label").has_theme_color_override("font_color"): get_node("UI/"+ resource_type.to_pascal_case() +"Label").remove_theme_color_override("font_color")
