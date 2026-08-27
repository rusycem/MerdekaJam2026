extends Node

func _ready() -> void:
	print("=== Running SeMaK VN Tree + Minigame Integration Tests ===")
	var passed = true
	
	# Load VNPlayer
	var vn_scene = load("res://runtime/VNPlayer.tscn")
	if not vn_scene:
		print("FAILED: Could not load VNPlayer.tscn")
		get_tree().quit(1)
		return
		
	var vn_inst = vn_scene.instantiate()
	add_child(vn_inst)
	
	# Create a mock VN story tree with a Command node calling minigame error_hunt
	var tree = VNStoryTree.new()
	tree.graph_data = {
		"Start": {
			"type": "start",
			"next_node": "CallMinigame"
		},
		"CallMinigame": {
			"type": "command",
			"command": "minigame error_hunt",
			"next_node": "CheckResult"
		},
		"CheckResult": {
			"type": "condition",
			"condition": "minigame_won",
			"next_true": "WonDialogue",
			"next_false": "LostDialogue"
		},
		"WonDialogue": {
			"type": "dialogue",
			"speaker": "Teacher",
			"text": "Excellent grammar skills!",
			"next_node": ""
		},
		"LostDialogue": {
			"type": "dialogue",
			"speaker": "Teacher",
			"text": "Keep practicing your grammar!",
			"next_node": ""
		}
	}
	
	# Test running command node handler directly
	var cmd_data = tree.graph_data["CallMinigame"]
	
	var state = {"minigame_started": false, "received_id": ""}
	var start_handler = func(id: String):
		state["minigame_started"] = true
		state["received_id"] = id
	EventBus.start_minigame.connect(start_handler)
	
	# Trigger handler in background
	var coroutine = func():
		VNCommandHandler.handle(vn_inst, cmd_data)
	coroutine.call()
	
	if not state["minigame_started"]:
		print("FAILED: VNCommandHandler did not emit EventBus.start_minigame")
		passed = false
	elif state["received_id"] != "error_hunt":
		print("FAILED: Expected minigame_id 'error_hunt', got '%s'" % state["received_id"])
		passed = false
	else:
		print("PASSED: VNCommandHandler properly emitted start_minigame with 'error_hunt'")
		
	# Emit minigame_finished to let handler resume
	GameState.last_minigame_result = true
	EventBus.minigame_finished.emit()
	
	# Verify that current node progressed to CheckResult
	if vn_inst.current_node_id != "CheckResult":
		print("FAILED: VNPlayer did not progress to next node, current: '%s'" % vn_inst.current_node_id)
		passed = false
	else:
		print("PASSED: VNPlayer progressed smoothly after minigame completion.")
		
	# Test "minigame play error_hunt" syntax as well
	cmd_data["command"] = "minigame play error_hunt"
	state["minigame_started"] = false
	state["received_id"] = ""
	coroutine.call()
	
	if state["received_id"] != "error_hunt":
		print("FAILED: 'minigame play error_hunt' did not resolve to 'error_hunt', got '%s'" % state["received_id"])
		passed = false
	else:
		print("PASSED: 'minigame play error_hunt' resolved correctly to 'error_hunt'.")
	EventBus.minigame_finished.emit()
	
	EventBus.start_minigame.disconnect(start_handler)
	
	if passed:
		print("=== ALL VN INTEGRATION TESTS PASSED! ===")
		get_tree().quit(0)
	else:
		print("=== VN INTEGRATION TESTS FAILED ===")
		get_tree().quit(1)
