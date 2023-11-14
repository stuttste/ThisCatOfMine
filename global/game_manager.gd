extends Node

const SAVE_PATH = "user://savegame.bin"
const LEVEL_UP_DC = 16
const SKILL_TYPES = [
	"grit",
	"dexterity",
	"alpha_rating"
]
const RESOURCE_TYPES = [
	"food",
	"yarn",
	"straw",
	"cardboard",
	"cats"
]

signal game_won_sig()
signal game_lost_sig(reason)

var load_game_data = {}

var new_game = true
var game_completed = false
var felix_recruited = false
var raya_recruited = false

var food : int = 1
var yarn: int = 0
var straw: int = 0
var cardboard: int = 0
var cats: int = 1

var day = 1
var max_day = 14
var day_part = "morning"
var target_cats: int = 200

func initialize_new_game():
	new_game = true
	game_completed = false
	felix_recruited = false
	raya_recruited = false
	food = 1
	yarn = 0
	straw = 0
	cardboard = 0
	cats = 1
	day = 1
	max_day = 7
	day_part = "morning"
	target_cats = 200

func add_resource(resource_name, resource_amt):
	if "food" == resource_name: food += resource_amt
	if "yarn" == resource_name: yarn += resource_amt
	if "straw" == resource_name: straw += resource_amt
	if "cardboard" == resource_name: cardboard += resource_amt
	if "cats" == resource_name: cats += resource_amt

func progress_day():
	if day_part == "morning": day_part = "afternoon"
	elif day_part == "afternoon": day_part = "night"
	
	#process all game functions to proceed to next day
	else:
		var resource_shortage = false
		var resource_need_amt = calculate_resource_need("")
		for resource_type in RESOURCE_TYPES:
			if resource_type != "food":
				if get_resource_amt_by_string(resource_type) < resource_need_amt: resource_shortage = true
		
		if resource_shortage: cats = max(cats - 5, 0)
		
		if food == 0: game_lost("Milo ran out of food!")
		else: food -= 1
		
#		if day != max_day:
#			day += 1
#			day_part = "morning"
#		else:
		if cats >= target_cats: game_won()
		#else: game_lost("Milo failed to recruit enough cats.")

func get_resource_amt_by_string(resource_type):
	if "food" == resource_type: return food
	elif "yarn" == resource_type: return yarn
	elif "straw" == resource_type: return straw
	elif "cardboard" == resource_type: return cardboard
	elif "cats" == resource_type: return cats
	else: return null

func calculate_resource_need(resource):
	if resource == "food": return 1
	else: return floor(cats * 0.75)

func game_won():
	game_won_sig.emit()

func game_lost(reason):
	game_lost_sig.emit(reason)

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data: Dictionary = {
		"new_game": new_game,
		"game_completed": game_completed,
		"felix_recruited": felix_recruited,
		"raya_recruited": raya_recruited,
		"day": day,
		"day_part": day_part,
		"food": food,
		"yarn": yarn,
		"straw": straw,
		"cardboard": cardboard,
		"cats": cats
	}
	
	var cat_nodes = get_tree().get_nodes_in_group("Cat")
	for cat in cat_nodes:
		data[cat.cat_name] = {
			"grit": cat.grit,
			"dexterity": cat.dexterity,
			"alpha_rating": cat.alpha_rating
		}
	
	var jstr = JSON.stringify(data)
	file.store_line(jstr)
	
func load_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_PATH):
		if not file.eof_reached():
			var current_line = JSON.parse_string(file.get_line())
			load_game_data = current_line
			if current_line:
				GameManager.new_game = current_line["new_game"]
				GameManager.game_completed = current_line["game_completed"]
				GameManager.felix_recruited = current_line["felix_recruited"]
				GameManager.raya_recruited = current_line["raya_recruited"]
				GameManager.day = current_line["day"]
				GameManager.day_part = current_line["day_part"]
				GameManager.food = current_line["food"]
				GameManager.yarn = current_line["yarn"]
				GameManager.straw = current_line["straw"]
				GameManager.cardboard = current_line["cardboard"]
				GameManager.cats = current_line["cats"]
				
	if game_completed:
		load_game_data = {}
		initialize_new_game()
		return false
	else:
		return true
		
