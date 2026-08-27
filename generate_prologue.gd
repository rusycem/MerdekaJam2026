extends SceneTree

func _init():
	var tree = VNStoryTree.new()
	
	tree.graph_data = {
		"Start": {
			"type": "start",
			"position": [0, 0],
			"next_node": "IntroDialogue"
		},
		"IntroDialogue": {
			"type": "dialogue",
			"speaker": "Principal",
			"text": "Welcome to school, {player}. Choose your tablemate wisely. They could be your best friend for life.",
			"position": [200, 0],
			"next_node": "ChooseCompanion"
		},
		"ChooseCompanion": {
			"type": "choice_branch",
			"prompt": "Who will you sit next to, {player}?",
			"choices": [
				{"text": "Sit with Mirul", "condition": "", "hide_if_locked": false},
				{"text": "Sit with Alyssa", "condition": "", "hide_if_locked": false},
				{"text": "Sit with Vihaan", "condition": "", "hide_if_locked": false}
			],
			"next_nodes": ["MirulFlag", "AlyssaFlag", "VihaanFlag"],
			"position": [500, 0]
		},
		
		# ================= Mirul Route =================
		"MirulFlag": {
			"type": "command",
			"command": "flag add companion_mirul",
			"position": [900, -300],
			"next_node": "MirulIntro"
		},
		"MirulIntro": {
			"type": "dialogue",
			"speaker": "Principal",
			"text": "I see you have met my son, don't let his attitude fool you, he is just having his teenage angst phase.",
			"position": [1200, -300],
			"next_node": "MirulCheck"
		},
		"MirulCheck": {
			"type": "dnd_check",
			"target_stat": "Charm",
			"dc_value": 8,
			"position": [1500, -300],
			"next_pass": "MirulPass",
			"next_fail": "MirulFail"
		},
		"MirulPass": {
			"type": "dialogue",
			"speaker": "Mirul",
			"text": "Whatever, {player}. Just don't get in my way.",
			"position": [1800, -400],
			"set_flags": "mirul_likes_you",
			"next_node": "MirulHub"
		},
		"MirulFail": {
			"type": "dialogue",
			"speaker": "Mirul",
			"text": "... (He ignores you completely)",
			"position": [1800, -200],
			"next_node": "MirulHub"
		},
		"MirulHub": {
			"type": "command",
			"command": "start_hub 3", # Start activity phase with 3 turns
			"position": [2100, -300],
			"next_node": "MirulEnd"
		},
		"MirulEnd": {
			"type": "dialogue",
			"speaker": "{player}",
			"text": "Phew, that training was tough! Time to head back to the dorm.",
			"position": [2400, -300],
			"next_node": "" # End of tree
		},
		
		# ================= Alyssa Route =================
		"AlyssaFlag": {
			"type": "command",
			"command": "flag add companion_alyssa",
			"position": [900, 0],
			"next_node": "AlyssaIntro"
		},
		"AlyssaIntro": {
			"type": "dialogue",
			"speaker": "Principal",
			"text": "Ohh great, she is a great example for you to follow, I'm sure you guys will get along.",
			"position": [1200, 0],
			"next_node": "AlyssaMoney"
		},
		"AlyssaMoney": {
			"type": "command",
			"command": "reward money 50",
			"position": [1500, 0],
			"next_node": "AlyssaCheckMoney"
		},
		"AlyssaCheckMoney": {
			"type": "condition",
			"condition": "has_flag companion_alyssa", # Using condition node to test flag
			"position": [1800, 0],
			"next_true": "AlyssaEnd",
			"next_false": "AlyssaEnd"
		},
		"AlyssaEnd": {
			"type": "dialogue",
			"speaker": "Alyssa",
			"text": "Hi {player}! I see you got your allowance. Let's study together later!",
			"position": [2100, 0],
			"next_node": ""
		},
		
		# ================= Vihaan Route =================
		"VihaanFlag": {
			"type": "command",
			"command": "flag add companion_vihaan",
			"position": [900, 300],
			"next_node": "VihaanIntro"
		},
		"VihaanIntro": {
			"type": "dialogue",
			"speaker": "Principal",
			"text": "Vihaan is a bit quiet, but if you talk to him I'm sure he will open up to you eventually.",
			"position": [1200, 300],
			"next_node": "VihaanMinigame"
		},
		"VihaanMinigame": {
			"type": "command",
			"command": "minigame clicker",
			"position": [1500, 300],
			"next_node": "VihaanEnd"
		},
		"VihaanEnd": {
			"type": "dialogue",
			"speaker": "Vihaan",
			"text": "You... you beat my high score, {player}. Not bad.",
			"position": [1800, 300],
			"next_node": ""
		}
	}
	
	# Save the resource!
	var err = ResourceSaver.save(tree, "res://scenes/StoryScene/prologue_test.tres")
	if err == OK:
		print("Successfully saved prologue_test.tres!")
	else:
		print("Failed to save: ", err)
		
	quit()
