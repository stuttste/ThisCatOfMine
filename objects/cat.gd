extends Node2D

@export var cat_name = "Alex"
@export var texture_path = "res://art/Cat-1-Portrait.png"
@export var dexterity = 5
@export var grit = 5
@export var alpha_rating = 5

const MIN_DRAGNDROP_DISTANCE = 40

var default_location
var mission_locations = []
var assigned_mission = null
var selected = false
var popout_visible = false

func _draw():
	draw_circle(Vector2(-0.5, -1), 5, Color.DARK_SLATE_GRAY)

# Called when the node enters the scene tree for the first time.
func _ready():
	default_location = self.position
	$Sprite2D.texture = load(texture_path)
	
	#Make sure popout is visible. Typically toggled off in the editor
	$CatUI.visible = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if popout_visible: $CatUI/Popout.show()
	else: $CatUI/Popout.hide()
	
	update_popout()

func _physics_process(delta):
	#Drag sprite when clicked
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

func _input(event):
	if event is InputEventMouseButton:
		if selected and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			selected = false
			var mission = get_nearest_mission_node()
			if mission: 
				assign_cat(mission)
			else: 
				unassign_cat()

func _on_area_2d_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("Click"):
		selected = true
		get_mission_nodes()
	elif Input.is_action_just_pressed("RClick"):
		unassign_cat()

func get_mission_nodes():
	mission_locations = get_tree().get_nodes_in_group("Mission")
	
func get_nearest_mission_node():
	var smallest_distance = null
	var smallest_distance_mission
	for mission in mission_locations:
		var distance = global_position.distance_to(mission.global_position)
		if not smallest_distance or distance < smallest_distance: 
			smallest_distance = distance
			smallest_distance_mission = mission
			
	if smallest_distance <= MIN_DRAGNDROP_DISTANCE: return smallest_distance_mission
	else: return null

func assign_cat(mission):
	if mission.has_method("assign_cat_to_mission"):
		self.position = mission.global_position
		assigned_mission = mission
		mission.assign_cat_to_mission(self)

func unassign_cat():
	self.position = default_location
	if assigned_mission and assigned_mission.has_method("unassign_cat_from_mission"):
		assigned_mission.unassign_cat_from_mission()
		assigned_mission = null
		
func skill_level_up(skill):
	if skill == "dexterity" and dexterity < 5: 
		dexterity = dexterity + 1
	elif skill == "grit" and grit < 5: 
		grit += 1
	elif skill == "alpha_rating" and alpha_rating < 5: 
		alpha_rating += 1

func get_skill_level(skill):
	if skill == "dexterity": return dexterity
	elif skill == "grit": return grit
	elif skill == "alpha_rating": return alpha_rating

func update_popout():
	#populate Popout
	$CatUI/Popout/PopoutCatName.text = cat_name.to_pascal_case()
	$CatUI/Popout/PopoutSkillList.clear()
	$CatUI/Popout/PopoutSkillList.add_item("Alpha:")
	$CatUI/Popout/PopoutSkillList.add_item(str(alpha_rating))
	$CatUI/Popout/PopoutSkillList.add_item("Dexterity:")
	$CatUI/Popout/PopoutSkillList.add_item(str(dexterity))
	$CatUI/Popout/PopoutSkillList.add_item("Grit:")
	$CatUI/Popout/PopoutSkillList.add_item(str(grit))

func _on_area_2d_mouse_entered():
	if not selected: popout_visible = true


func _on_area_2d_mouse_exited():
	popout_visible = false
