extends Node

func _ready() -> void:
	print("=== Running Comprehensive Error Hunt Multi-Format Tests ===")
	var passed = true
	
	# Test 1: Load Scene and Data
	var scene_res = load("res://minigames/ErrorHuntGame.tscn")
	if not scene_res:
		print("FAILED: Could not load res://minigames/ErrorHuntGame.tscn")
		get_tree().quit(1)
		return
	print("PASSED: res://minigames/ErrorHuntGame.tscn loaded successfully.")
	
	var data_res = ErrorHuntData.QUESTIONS
	print("Total questions in ErrorHuntData: %d" % data_res.size())
	if data_res.size() < 200:
		print("FAILED: Expected at least 200 questions, found %d" % data_res.size())
		passed = false
	else:
		print("PASSED: Found %d questions (>= 200 requirement satisfied)." % data_res.size())
		
	# Test 2: Validate Question Formats and Data Integrity
	var type_counts = {}
	for i in range(data_res.size()):
		var q = data_res[i]
		var q_type = q.get("type", "")
		type_counts[q_type] = type_counts.get(q_type, 0) + 1
		
		var corr_idx = q.get("correct_index", -1)
		if q_type == "word_tap":
			var words = q.get("words", [])
			if corr_idx < 0 or corr_idx >= words.size():
				print("FAILED: Question #%d (word_tap) invalid correct_index %d for words %s" % [i, corr_idx, str(words)])
				passed = false
		elif q_type in ["mcq_error", "mcq_fix", "sentence_spotter"]:
			var opts = q.get("options", [])
			if corr_idx < 0 or corr_idx >= opts.size():
				print("FAILED: Question #%d (%s) invalid correct_index %d for options %s" % [i, q_type, corr_idx, str(opts)])
				passed = false
		else:
			print("FAILED: Unknown question type: %s" % q_type)
			passed = false
			
	for t in type_counts.keys():
		print("  - Format '%s': %d questions" % [t, type_counts[t]])
		
	if type_counts.size() < 4:
		print("FAILED: Expected 4 question variants, found %d" % type_counts.size())
		passed = false
	else:
		print("PASSED: All 4 question variants are present and populated.")
		
	# Test 3: Simulation & Game Lifecycle
	var instance = scene_res.instantiate()
	add_child(instance)
	
	# Verify initial state
	if instance.time_left != 60.0:
		print("FAILED: Initial time_left should be 60.0, got %f" % instance.time_left)
		passed = false
	if instance.score != 0:
		print("FAILED: Initial score should be 0, got %d" % instance.score)
		passed = false
	if instance.target_score != 100:
		print("FAILED: Target score should be 100, got %d" % instance.target_score)
		passed = false
		
	# Test interactive tap
	var prev_score = instance.score
	var q = instance.current_question
	var corr = q.get("correct_index", 0)
	var wrong = 0 if corr != 0 else 1
	
	# Dummy button
	var btn = Button.new()
	instance.add_child(btn)
	
	# Incorrect tap
	if q.get("type") == "word_tap":
		instance._on_word_pressed(wrong, btn)
	else:
		instance._on_option_pressed(wrong, btn)
	if instance.score != prev_score:
		print("FAILED: Incorrect tap modified score! Expected %d, got %d" % [prev_score, instance.score])
		passed = false
	else:
		print("PASSED: Incorrect tap did not add points.")
		
	# Correct tap
	if q.get("type") == "word_tap":
		instance._on_word_pressed(corr, btn)
	else:
		instance._on_option_pressed(corr, btn)
	if instance.score != prev_score + 10:
		print("FAILED: Correct tap did not add 10 points! Expected %d, got %d" % [prev_score + 10, instance.score])
		passed = false
	else:
		print("PASSED: Correct tap awarded +10 points.")
		
	# Test Win/Loss Result Logic
	instance.score = 60
	instance._end_game()
	if GameState.last_minigame_result != false:
		print("FAILED: Score 60 should produce GameState.last_minigame_result = false")
		passed = false
	else:
		print("PASSED: Score 60 correctly set GameState.last_minigame_result = false")
		
	instance.score = 110
	instance._end_game()
	if GameState.last_minigame_result != true:
		print("FAILED: Score 110 should produce GameState.last_minigame_result = true")
		passed = false
	else:
		print("PASSED: Score 110 correctly set GameState.last_minigame_result = true")
		
	# Test Signal on Return
	var sig_state = {"emitted": false}
	var sig_handler = func(): sig_state["emitted"] = true
	EventBus.minigame_finished.connect(sig_handler)
	instance._on_return_pressed()
	
	if not sig_state["emitted"]:
		print("FAILED: _on_return_pressed did not emit EventBus.minigame_finished")
		passed = false
	else:
		print("PASSED: EventBus.minigame_finished emitted on return.")
		
	EventBus.minigame_finished.disconnect(sig_handler)
	
	if passed:
		print("=== ALL COMPREHENSIVE TESTS PASSED SUCCESSFULLY! ===")
		get_tree().quit(0)
	else:
		print("=== TESTS FAILED ===")
		get_tree().quit(1)
