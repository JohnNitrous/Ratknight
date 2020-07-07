extends MarginContainer

#Just the current monsters stats... because why not?
var monster_stat_health = 0
var monster_stat_attack = 0
var monster_experience = 0

#all player variables are in this "global" variable
onready var player = $"/root/player_variables"

#Tool to make sure the stats are randomly created
var rand_generate = RandomNumberGenerator.new()

#Used to clean up error messages.
var all_the_text = ""

var life_state = "alive"

func start_adventure():
	var adventure = ["Greetings brave adventurer!", "Welcome to RATKNIGHT!", "To start choose a class please! [NOT IMPLEMENTED YET]", "Now that everything is set, write FIGHT to find an enemy and hit ENTER."]
	for line in adventure:
		if (line != adventure[0]):
			$viewcontainer/output.set_text($viewcontainer/output.get_text() + line + "\n")
		else:
			$viewcontainer/output.set_text(line + "\n")
	wait_for_input("ANY")

func wait_for_input(type):
	yield($viewcontainer/input, "text_entered")
	var command = $viewcontainer/input.get_text().to_upper()
	$viewcontainer/input.clear()
	if (all_the_text != ""):
		$viewcontainer/output.set_text(all_the_text)
		all_the_text = ""
	if (27 < $viewcontainer/output.get_line_count()):
		$viewcontainer/output.set_text("")
	match type:
		"ANY":
			match command:
				"FIGHT":
					summon_monster()
				_:
					invalid_function(type, command, "wait for input")
		"WANNA FIGHT HUH":
			match command:
				"ATTACK":
					fight_monster("none")
				"BAIL":
					bail_fight()
				_:
					invalid_function(type, command, "wait for input")
		"IN FIGHT":
			match command:
				"HEAL":
					fight_monster("heal")
				"ATTACK":
					fight_monster("attack")
				"STATS":
					fight_monster("stats")
				_:
					invalid_function(type, command, "wait for input")
		"NEW ACTION":
			match command:
				"STATS":
					show_stats("NEW ACTION")
				"FIGHT":
					summon_monster()
				_:
					invalid_function(type, command, "wait for input")

func summon_monster():
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Summoning a monster." + "\n")
	rand_generate.randomize()
	monster_stat_attack = rand_generate.randi_range(1,3) * player.current_level
	rand_generate.randomize()
	monster_stat_health = rand_generate.randi_range(1,3) * player.current_level
	monster_experience = monster_stat_health
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "A rat with " + str(monster_stat_attack) + "AP and " + str(monster_stat_health) + "HP appeared.\nIf you want to fight write ATTACK, if you want to bail write BAIL and hit ENTER afterwards, no shame in bailing by the way." + "\n")
	wait_for_input("WANNA FIGHT HUH")

func bail_fight():
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Bailing might have been the smartest decision." + "\n")
	do_something_else("NEW ACTION")

func fight_monster(type):
	var command = $viewcontainer/input.get_text().to_upper()
	$viewcontainer/input.clear()
	var current_action = "IN FIGHT"
	match type:
		"none":
			$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Good luck, adventurer!\n" + "To fight the rat type ATTACK, to heal yourself type HEAL and to see all the stats type STATS and hit ENTER afterwards.\n")
			wait_for_input("IN FIGHT")
		"stats":
			show_stats(current_action)
		"heal":
			healing_yourself(current_action)
		"attack":
			attacking_monster(current_action)
		_:
			if (life_state == "alive"):
				invalid_function(type, command, "fight monster")

func show_stats(current_action):
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Your current stats are\n" + str(player.health) + "HP, " + str(player.attack_points) + "AP, "  + str(player.experience_points) + "XP, Level " + str(player.current_level) + "\n")
	if (current_action == "IN FIGHT"):
		$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Your enemies' stats are\n" + str(monster_stat_health) + "HP and " + str(monster_stat_attack) + "AP\n")
	wait_for_input(current_action)

func attacking_monster(current_action):
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Attacking the rat" + "\n")
	rand_generate.randomize()
	var attack_succesful = rand_generate.randi_range(1,6)
	if (attack_succesful != 2):
		var attack_points
		rand_generate.randomize()
		var critical_hit = rand_generate.randi_range(1,10)
		if (critical_hit == 3):
			attack_points = player.attack_points * 3
		else:
			attack_points = player.attack_points
		monster_stat_health -= attack_points
		if (monster_stat_health > 0):
			$viewcontainer/output.set_text($viewcontainer/output.get_text() + "You hit the rat and drained its HP by " + str(attack_points) + "HP, it's at " + str(monster_stat_health) + "HP now.\n")
		else:
			$viewcontainer/output.set_text($viewcontainer/output.get_text() + "You hit the rat and drained its HP by " + str(attack_points) + "HP, you have slain the rat!\n")
			calculate_experience()
			current_action = "NEW ACTION"
	else:
		$viewcontainer/output.set_text($viewcontainer/output.get_text() + "You missed!\n")
	if (current_action == "IN FIGHT"):
		life_state = monster_attack("fight")
		if (life_state == "alive"):
			wait_for_input(current_action)
	else:
		do_something_else(current_action)

func healing_yourself(current_action):
	rand_generate.randomize()
	var health = rand_generate.randi_range(1,3) * player.current_level
	player.health += health
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "You restored " + str(health) + "HP. That makes " + str(player.health) + "HP in total.\n")
	life_state = monster_attack("heal")
	if (life_state == "alive"):
		wait_for_input(current_action)

func monster_attack(action):
	var attack_me = 3
	if (action == "heal"):
		rand_generate.randomize()
		attack_me = rand_generate.randi_range(1,3)
	rand_generate.randomize()
	var attack_succesful = rand_generate.randi_range(1,6)
	if (attack_succesful != 2):
		if (attack_me == 3):
			var attack_points
			rand_generate.randomize()
			var critical_hit = rand_generate.randi_range(1,10)
			if (critical_hit == 3):
				attack_points = monster_stat_attack * 3
			else:
				attack_points = monster_stat_attack
			player.health -= attack_points
			if (player.health > 0):
				$viewcontainer/output.set_text($viewcontainer/output.get_text() + "The rat hit you and decreased your HP by " + str(attack_points)  + "HP to " + str(player.health)  + "HP.\n")
				return "alive"
			else:
				$viewcontainer/output.set_text($viewcontainer/output.get_text() + "The rat hit you and decreased your HP by " + str(attack_points)  + "HP.\nYou died.\nGAME OVER\n")
				return "dead"
	else:
		$viewcontainer/output.set_text($viewcontainer/output.get_text() + "The rat tried to attack you, but missed!" + "\n")
		return "alive"
	return "alive"

func calculate_experience():
	rand_generate.randomize()
	var gained_experience = rand_generate.randi_range(1,3) * monster_experience
	player.experience_points += gained_experience
	var new_level = int(gained_experience/100)
	var xp_string = "You gained " + str(gained_experience) + "XP.";
	if (new_level > player.current_level):
		player.current_level = new_level
		xp_string += " You also leveled up to level " + str(new_level) + "!"
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + xp_string + "\n")

func do_something_else(current_action):
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "To find a new enemy type FIGHT, to see your stats type STATS!\n")
	wait_for_input(current_action)

func invalid_function(type, command, function):
	all_the_text = $viewcontainer/output.get_text()
	$viewcontainer/output.set_text($viewcontainer/output.get_text() + "Sorry, I didn't understand what you meant with \"" + command + "\", please try again!" + "\n")
	match function:
		"wait for input":
			wait_for_input(type)
		"fight monster":
			fight_monster(type)

func _ready():
	start_adventure()