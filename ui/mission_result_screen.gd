extends Control

signal screen_closed()

@onready var results_table = $Panel/MissionResults

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			queue_free()
			screen_closed.emit()

func render_results(results:Dictionary):
	$Panel/MissionResults.clear()
	$Panel/LevelUps.clear()
	$Panel/Totals.clear()
	
	var resource_totals = {}
	
	for mission_name in results.keys():
		var mission_results = results[mission_name]
		var added_the_first_one = false
		var cat_name = mission_results["cat"]
		var grouping_name = cat_name + " - " + mission_name
		
		$Panel/MissionResults.add_item(grouping_name)
		for resource in GameManager.RESOURCE_TYPES:
			if resource not in resource_totals: resource_totals[resource] = 0
			if resource in mission_results:
				if added_the_first_one: $Panel/MissionResults.add_item("")
				else: added_the_first_one = true
				resource_totals[resource] += mission_results[resource]
				$Panel/MissionResults.add_item(str(mission_results[resource]) + " " + resource)
				
				
		for skill in GameManager.SKILL_TYPES:
			if skill in mission_results:
				$Panel/LevelUps.add_item(cat_name + "'s " + skill + " leveled up by 1!")
				
	for resource_type in resource_totals.keys():
		$Panel/Totals.add_item("Total " + resource_type.to_pascal_case() + ":")
		$Panel/Totals.add_item(str(resource_totals[resource_type]))
		
