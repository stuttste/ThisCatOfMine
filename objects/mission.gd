extends Node2D

@export var location_name = "Back Alley"
@export var related_skill = "dexterity"
@export var resources : Dictionary = {
	"food_min":1,
	"food_max":2,
	"yarn_min":0,
	"yarn_max":2,
	"cardboard_min":0,
	"cardboard_max":2,
	"straw_min":0,
	"straw_max":0,
	"cats_min":0,
	"cats_max":1
}
var cat_assigned
var popout_visible

var most_recent_results: Dictionary = {}

func _draw():
	#issues from the scaling on the cat sprites, hence the weird vector location :P
	draw_circle(Vector2(-4, -8), 40, Color.DARK_GRAY)

func _ready():
	$MissionUI/LocationName.text = location_name
	
	#Make sure popout is visible. Typically toggled off in the editor
	$MissionUI/Popout.visible = true
	#Assign text for popout
	$MissionUI/Popout/PopoutLocationName.text = location_name
	$MissionUI/Popout/PopoutSkill.text = related_skill.to_pascal_case()
	#Remove debug items from the item list
	$MissionUI/Popout/ResourceList.clear()
	#Add actual items to popout
	for resource in GameManager.RESOURCE_TYPES:
		var resource_min = resources[str(resource + "_min")]
		var resource_max = resources[str(resource + "_max")]
		if resource_max > 0:
			$MissionUI/Popout/ResourceList.add_item(resource.to_pascal_case() + ":")
			$MissionUI/Popout/ResourceList.add_item(str(resource_min) + " ~ " + str(resource_max))

func _process(delta):
	if not cat_assigned and popout_visible: $MissionUI/Popout.show()
	else: $MissionUI/Popout.hide()

func go_on_mission():
	if cat_assigned:
		most_recent_results.clear()
		
		most_recent_results["cat"] = cat_assigned.cat_name
		#Calculate and add resources for the mission
		for resource in GameManager.RESOURCE_TYPES:
			var resource_amt = calculate_resource_amt(resource)
			GameManager.add_resource(resource, resource_amt)
			if resource_amt != 0:
				most_recent_results[resource] = resource_amt
		
		#Check if we leveled up a skill (Make sure this is AFTER the mission as you don't want the wrong bonus applied)
		var roll_value = randi_range(1, 20)
		if roll_value >= GameManager.LEVEL_UP_DC and cat_assigned.has_method("skill_level_up"):
			cat_assigned.skill_level_up(related_skill)
			most_recent_results[related_skill] = 1
		
func calculate_resource_amt(resource):
	if not(str(resource + "_min") in resources and str(resource + "_max") in resources):
		return null
	
	var generated_amt = randi_range(resources[str(resource + "_min")], resources[str(resource + "_max")])
	var skill_level = 0
	var calculated_increase = 0
	
	#Apply bonuses based on the relevant skill of the cat
	if cat_assigned.has_method("get_skill_level"):
		skill_level = cat_assigned.get_skill_level(related_skill)/10.0
		calculated_increase = ceil(generated_amt * skill_level)
		generated_amt += calculated_increase
	
	return generated_amt

func assign_cat_to_mission(cat):
	cat_assigned = cat

func unassign_cat_from_mission():
	cat_assigned = null

func _on_area_2d_mouse_entered():
	popout_visible = true


func _on_area_2d_mouse_exited():
	popout_visible = false
