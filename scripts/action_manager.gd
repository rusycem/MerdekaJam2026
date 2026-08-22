extends Control

# --- DEDICATED UI NODES (UPDATED PATHS) ---
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var hang_out_btn: Button = $VBoxContainer/HangOutButton
@onready var work_out_btn: Button = $VBoxContainer/WorkOutButton
@onready var study_btn: Button = $VBoxContainer/StudyButton
@onready var chores_btn: Button = $VBoxContainer/ChoresButton
@onready var buy_food_btn: Button = $VBoxContainer/BuyFoodButton
@onready var advance_btn: Button = $VBoxContainer/AdvanceButton

# --- ACTION PHASE STATE ---
var max_slots: int = 5
var current_slots: int = max_slots
var money: int = 10

var stats = {
	"charisma": 0,
	"dexterity": 0,
	"intelligence": 0
}

var physical_buff: bool = false

func _ready() -> void:
	hang_out_btn.pressed.connect(_on_hang_out_pressed)
	work_out_btn.pressed.connect(_on_work_out_pressed)
	study_btn.pressed.connect(_on_study_pressed)
	chores_btn.pressed.connect(_on_chores_pressed)
	buy_food_btn.pressed.connect(_on_buy_food_pressed)
	advance_btn.pressed.connect(_on_advance_pressed)
	money += 5
	
	update_ui_state()

func update_ui_state() -> void:
	title_label.text = "=== ACTION PHASE ===\nSlots Remaining: " + str(current_slots) + "/" + str(max_slots) + "\nMoney: $" + str(money)
	
	var has_slots: bool = current_slots > 0
	
	hang_out_btn.disabled = not has_slots
	work_out_btn.disabled = not has_slots
	study_btn.disabled = not has_slots
	chores_btn.disabled = not has_slots
	buy_food_btn.disabled = money < 20
	advance_btn.visible = not has_slots

func _on_hang_out_pressed() -> void:
	if not _use_slot(): return
	stats["charisma"] += 2
	print("Hung out! Charisma +2 (Total: ", stats["charisma"], ")")
	update_ui_state()

func _on_work_out_pressed() -> void:
	if not _use_slot(): return
	stats["dexterity"] += 2
	physical_buff = true
	print("Worked out! Dexterity +2 (Total: ", stats["dexterity"], ") | Physical checks buffed.")
	update_ui_state()

func _on_study_pressed() -> void:
	if not _use_slot(): return
	stats["intelligence"] += 2
	print("Studied! Intelligence +2 (Total: ", stats["intelligence"], ")")
	_start_practice_minigame()

func _on_chores_pressed() -> void:
	if not _use_slot(): return
	money += 10
	print("Chores done! Earned +RM10. Total money: RM", money)
	update_ui_state()

func _on_buy_food_pressed() -> void:
	if money >= 20:
		money -= 20
		print("Bought food! Remaining money: $", money, " (0 Slots used).")
	else:
		print("Not enough money!")
	update_ui_state()

func _on_advance_pressed() -> void:
	current_slots = max_slots
	physical_buff = false
	print("--- ADVANCING CHAPTER --- Slots reset to 3.")
	update_ui_state()

func _start_practice_minigame() -> void:
	print("30-Second Practice Started!")
	study_btn.disabled = true
	
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func():
		print("Practice finished!")
		update_ui_state()
	)

func _use_slot() -> bool:
	if current_slots <= 0: return false
	current_slots -= 1
	return true
