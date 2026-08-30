# Merdeka Jam 2026: The Comprehensive Programmer's Guide

Welcome to the definitive integration manual for **Gameplay and UI Programmers**. This document covers everything you need to know about extending the **SeMaK Visual Novel Engine**, hooking up new minigames, manipulating global state variables, and customizing the user interface (UI) to a high standard (e.g., Persona 5 style).

---

## 1. High-Level Architecture Overview

Merdeka Jam 2026 operates on a **Hybrid VN/RPG architecture**. It strictly separates logic, state, and presentation.

### Key Components

*   **`Main.tscn` / `Main.gd`:** The root Scene Manager. It controls two primary containers:
    *   `LevelContainer`: Holds the active 3D/2D world or the VN Engine (`VNPlayer.tscn`).
    *   `MenuContainer`: Holds floating UI, pause menus, and **Minigames** (which run *on top* of paused VN content).
    *   Listens to the **`EventBus.gd`** to know when to swap scenes, fading the screen to black automatically.
*   **`GameState.gd` (Autoload):** The persistent session tracker. It holds all variables, player money, stats, and narrative flags.
*   **`EventBus.gd` (Autoload):** The global signal router. It decouples the UI and Gameplay. For instance, the VN logic doesn't load a minigame directly; it shouts `start_minigame` to the EventBus, and `Main.gd` listens and handles the instantiation.
*   **The SeMaK Plugin (`addons/semak`):** A custom visual node editor built for Game Designers. It serializes a flowchart into a Godot Resource (`VNStoryTree`), specifically into a large Dictionary called `graph_data`.
*   **`VNPlayer.tscn` & `VNPlayer.gd`:** The runtime UI that actually displays the VN tree to the player.
*   **`VNPlayerHandlers.gd`:** A static utility class that bridges the SeMaK data dictionary and `VNPlayer.gd`. It parses the logic, applies animations, and handles node-to-node routing.

---

## 2. The SeMaK Plugin: How it Works Under the Hood

When a Game Designer saves a tree in the SeMaK editor, they are saving a `VNStoryTree` resource. Inside this resource is a dictionary called `graph_data`.

### 2.1 The Execution Loop
When `VNPlayer.gd` calls `play(story_tree)`, it sets `current_node_id` to the starting node and calls `_process_node()`.

```gdscript
# VNPlayer.gd - The core execution loop
func _process_node() -> void:
    # 1. Fetch current node's data dictionary
    var data = graph_data[current_node_id]
    var type = data["type"]
    
    # 2. Delegate execution to VNPlayerHandlers based on 'type'
    if type == "dialogue":
        VNPlayerHandlers.handle_dialogue(self, data)
    elif type == "choice_branch":
        VNPlayerHandlers.handle_choice(self, data)
    elif type == "command":
        VNPlayerHandlers.handle_command(self, data)
    # ... etc
```

### 2.2 What VNPlayerHandlers.gd Does
`VNPlayerHandlers.gd` reads the keys injected by the SeMaK editor nodes. 
For a **Dialogue Node**, the dictionary looks like this:
```json
{
    "type": "dialogue",
    "speaker": "Mirul",
    "text": "{Angry, HandsHips, shake} What are you doing, {player}?",
    "set_flags": "met_mirul",
    "next_node": "NodeID_12345"
}
```

The handler parses this data:
1.  **Regex Tag Parsing:** It uses Regex `\\{([A-Za-z0-9_:, ]+)\\}` to strip out `{Angry, HandsHips, shake}` from the text.
2.  **Animation:** It looks up the active sprite for "mirul", sets the texture to `HandsHips_Angry`, and uses a `Tween` to perform the `shake` animation.
3.  **Flag Injection:** It talks to `GameState.grant_flags("met_mirul")`.
4.  **UI Update:** It tells `VNPlayer.gd` to type out the text in the Dialogue Panel.

---

## 3. Global Variables, Stats, and Logic (GameState.gd)

If you are a Gameplay Programmer adding new mechanics (like an affection meter, a time-of-day system, or an inventory), you will modify `GameState.gd`.

### 3.1 Existing Variables
*   `GameState.flags` (Array): String tags like `"knows_secret"`.
*   `GameState.money` (Int).
*   `GameState.stats` (Dictionary): `"Charm"`, `"Intelligence"`, `"Courage"`, `"Dexterity"`.

### 3.2 Accessing and Modifying State via Code
```gdscript
# Checking conditions
if GameState.has_flag("met_mirul") and GameState.money >= 50:
    print("Player is rich and knows Mirul.")

# Granting / Removing
GameState.grant_flags("has_vip_pass, drank_coffee")
GameState.remove_flag("has_vip_pass")
```

### 3.3 Extending GameState for New Features
If you want to add an Inventory system:
1. Open `GameState.gd`.
2. Add: `var inventory: Array[String] = []`
3. Add a helper: `func has_item(item: String) -> bool: return inventory.has(item)`
4. Modify `evaluate_condition()` to support this in SeMaK.
   
```gdscript
# Inside GameState.gd -> evaluate_condition(cond: String)
if cond.begins_with("has_item_"):
    var item_name = cond.replace("has_item_", "").strip_edges()
    return has_item(item_name)
```
*Result:* Designers can now use `has_item_golden_key` inside SeMaK Condition Nodes!

---

## 4. Integrating Minigames: A Step-by-Step Guide

Game Designers use the SeMaK **Command Node** to write `minigame play [minigame_id]`.
Here is how you, the programmer, implement that hook.

### Step 1: Create the Minigame Scene
Create a new standalone scene (e.g., `res://minigames/RhythmGame.tscn`).
*   It should be a `Control` node (so it anchors to the UI).
*   It should **not** rely on `Main.gd` cameras or world space.

### Step 2: Hook up the Win/Loss State
When the minigame ends, you MUST tell the VN Engine what the result was, emit the finish signal, and delete the minigame.

```gdscript
# RhythmGame.gd
func _on_game_over(player_won: bool):
    # 1. Save the result to the global state
    GameState.last_minigame_result = player_won
    
    # 2. Tell the EventBus we are done (resumes the VN)
    EventBus.minigame_finished.emit()
    
    # 3. Destroy the minigame scene
    queue_free()
```

### Step 3: Register the Minigame in Main.gd
Open `src/Main.gd` and find `_on_start_minigame(minigame_id: String)`.

```gdscript
# Main.gd
func _on_start_minigame(minigame_id: String) -> void:
    var path = ""
    if minigame_id == "clicker":
        path = "res://minigames/ClickerGame.tscn"
    elif minigame_id == "rhythm": # <--- YOU ADD THIS
        path = "res://minigames/RhythmGame.tscn" 
        
    if path != "":
        var mg_scene = load(path)
        var instance = mg_scene.instantiate()
        # Spawns it over the VNPlayer
        menu_container.add_child(instance)
    else:
        # Failsafe: if ID is wrong, resume the VN immediately
        EventBus.minigame_finished.emit() 
```

### Step 4: Designer Usage
The designer drops a Command Node in SeMaK:
`minigame play rhythm`
Followed by a Condition Node:
`minigame_won` (True/False branches).

---

## 5. Customizing UI: Achieving the "Persona 5" Look

The UI is entirely encapsulated within `res://runtime/VNPlayer.tscn` and its script `VNPlayer.gd`. 

### 5.1 Restructuring VNPlayer.tscn
Currently, it uses standard Godot `PanelContainer` and `VBoxContainer` nodes.
To make it pop like Persona 5:
1.  **Replace Panels with Custom TextureRects:** Remove the flat backgrounds of `DialoguePanel`. Use stylized speech bubble sprites or slanted polygons.
2.  **Custom Fonts & Outlines:** Apply a dynamic font with heavy outlines and shadows via Godot's Theme Overrides.
3.  **Positioning:** Break away from rigid VBoxContainers if you want dynamic, slanted angles.

### 5.2 Modifying Animations in VNPlayerHandlers.gd
When characters enter or change emotions, it looks stiff. You can rewrite the animation logic in `VNPlayerHandlers.gd`.

Locate the `anim_to_play` block in `handle_dialogue`:
```gdscript
# In VNPlayerHandlers.gd -> handle_dialogue()
if anim_to_play == "bounce":
    # Old: Basic up/down
    # NEW: Persona-style squash and stretch
    tw.tween_property(sprite, "scale", Vector2(1.1, 0.9), 0.05)
    tw.tween_property(sprite, "position:y", orig_pos.y - 30, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
    tw.tween_property(sprite, "scale", Vector2(0.9, 1.1), 0.1)
    tw.tween_property(sprite, "position:y", orig_pos.y, 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
    tw.tween_property(sprite, "scale", Vector2(1, 1), 0.1)
```

### 5.3 Dialogue Transitions
To make text appear in a cooler way than just `visible_characters` left-to-right:
Instead of utilizing a standard `Label`, you can replace `TextLabel` in `VNPlayer.tscn` with a `RichTextLabel`. Godot 4 `RichTextLabel` supports custom BBCode text effects (e.g., `[wave]`, `[shake]`, `[tornado]`).
*Note: Our engine already strips `{Tags}` for animations, but you can safely pass BBCode directly through to the `RichTextLabel`.*

### 5.4 Improving the Choice Menu
In `VNPlayerHandlers.gd -> handle_choice()`:
```gdscript
# Instead of basic Buttons:
var btn = preload("res://src/UI/StylizedChoiceButton.tscn").instantiate()
btn.set_text(choice.text)
# Add rotation or scale tweens on hover!
```

---

## 6. Custom Audio & Sound Effects

### 6.1 Typewriter / Voice Blips
In `VNPlayer.gd`, the `_process` function plays a blip sound every 2 characters.
```gdscript
if last_visible_characters % 2 == 0 and blip_player.stream:
    # Pitch modulation for variety
    blip_player.pitch_scale = current_blip_pitch + randf_range(-0.05, 0.05)
    blip_player.play()
```
*   **Feature Expansion:** If you want different characters to have distinct instruments (like Animal Crossing), modify the `CharacterProfile.gd` resource to include a `blip_stream: AudioStream` variable, and load it here.

### 6.2 Voice Acting Support
SeMaK Dialogue nodes accept a Voice Audio UID.
In `VNPlayerHandlers.gd`:
```gdscript
var voice_uid = data.get("voice_audio_uid", "")
if voice_uid != "":
    var stream = ResourceLoader.load(voice_uid)
    player.voice_player.stream = stream
    player.voice_player.play()
    # Note: When voice plays, the typewriter blip is suppressed automatically!
```

### 6.3 SFX via Command Nodes
Want the designer to trigger a "Punch" sound effect mid-dialogue?
1. Open `VNPlayerHandlers.gd -> handle_command()`
2. Add a new command parser:
```gdscript
elif cmd.begins_with("sfx play"):
    var parts = cmd.split(" ", false)
    if parts.size() > 2:
        var uid = parts[2]
        # Play the sound using your AudioManager autoload
        AudioManager.play_sfx(uid)
```
*Designer usage:* `Command Node: sfx play uid://12345`

---

## 7. Troubleshooting & Important Rules

*   **Rule 1: Deterministic Saves.** Everything the player achieves must be saved in `GameState.gd` (flags, stats, relationships). DO NOT store vital progression data in `Main.gd` or `VNPlayer.gd`, as those scenes are wiped from memory on transition.
*   **Rule 2: Signal Hookups (Godot 4).** Remember that connecting a signal that is already connected throws an error. If doing dynamic UI generation in loops, use `if not btn.pressed.is_connected(my_func): btn.pressed.connect(my_func)`.
*   **Rule 3: Path UIDs vs String Paths.** The engine aggressively uses UIDs (`uid://xyz`) for backgrounds and voice acting to prevent breaking when designers rename files. Always use `ResourceLoader.load(uid)` rather than raw string paths.

---
**End of Programmer Guide.** Use this documentation as your primary reference for expanding Merdeka Jam 2026.
