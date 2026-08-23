# Technical Design Document (TDD)
**Project Name:** MerdekaJam 2026  
**Engine:** Godot 4.3 (GDScript)  
**Genre:** 2D Visual Novel / RPG Hybrid

---

## 1. Introduction

### Technical Goals & Purpose
The objective of this project is to create a modular, scalable Visual Novel/RPG hybrid using Godot. The core technical mandate is the implementation of **SeMaK**, a custom node-based visual scripting editor built directly into the Godot Editor. This ensures Game Designers can build complex branching logic, emotional state changes, and stat checks without requiring engineering support.

### Target Platform: PC & Mobile
This project is engineered primarily for **PC (Windows/Mac/Linux)**, with architectural considerations for future **Mobile (Android/iOS)** deployment.
- **Hardware Profile:** Low-to-mid range PC, standard mobile devices.
- **Rendering Backend:** Forward+ for PC, falling back to Vulkan Mobile/Compatibility for eventual mobile ports.
- **Aspect Ratio:** 16:9 base resolution (e.g., 1920x1080), utilizing canvas_items stretch mode to scale cleanly across devices.

### Branch Policy (Git Flow)
- master / main: Stable production builds. Only updated via pull requests from develop.
- develop: Main integration branch. All features merge here.
- eature/[name]: Active development branches for new mechanics.
- elease/[version]: Final stabilization branch for a milestone build.
- hotfix/[name]: Emergency patching for the main branch.

---

## 2. Technical Overview

### Naming Conventions & Coding Standards
- **GDScript (Classes/Nodes):** PascalCase (e.g., CharacterProfile.gd, VNPlayerHandlers.gd).
- **GDScript (Variables/Functions):** snake_case (e.g., current_node_id, handle_dialogue()).
- **Assets:** snake_case (e.g., mirul_happy.png, g_dorm_night.jpg).

### Data Layout
Player state and campaign progression are strictly isolated to ensure deterministic save/loads.
- **Runtime State:** Encapsulated entirely in the GameState.gd Autoload. It stores arrays of strings (flags), dictionaries (stats), and integers (currency, turns).
- **Save States:** Handled by SaveManager.gd. The GameState is serialized via JSON.stringify() and written to user://saves/[slot].json. 
- **Volatile State:** Scene-specific data (e.g., current VN dialogue index, UI animation tweens) are dropped completely when moving between the Hub and VN scenes to prevent memory leaks.

### Performance Budgets
- **Graphics / Rendering:** Focuses on lightweight 2D rendering. Draw calls are minimized via Texture Atlases where possible.
- **Game Logic:** Parsing of VN nodes is processed dynamically, maintaining a tiny CPU footprint.
- **Memory Footprint:** Actively managed by the Scene Manager (Main.gd), ensuring older VN branches and heavy audio files are purged from memory between scenes.

---

## 3. Game Mechanics & Architecture

### Core Game Loop
1. **Main Menu:** Loads save data via SaveManager.
2. **Dorm (Hub):** A time-management state. Players spend 'Turns' to trigger specific Story Chapters.
3. **VN Engine:** Main.gd loads VNPlayer.tscn. The engine parses the selected VNStoryTree (a custom Resource) and executes dialogue, stat checks, and background animations.
4. **Minigame Interruption:** A Command Node can pause the VN tree and push a Minigame scene onto the active tree. The Minigame resolves, emits an EventBus signal, and control is returned to the VN Engine.

### Primary Game Structures (Data-Oriented Approach)
- **Entities:** Instead of deep inheritance trees, characters are defined by lightweight CharacterProfile Resources that map strings (emotions) to 2D textures.
- **Levels:** Main.gd acts as a root SceneManager. It clears its LevelContainer and MenuContainer before instantiating new scenes to ensure absolute memory isolation.
- **UI:** Managed via a global Theme (.tres). Dialogue panels are built using robust Godot Control nodes configured to anchor properly across different screen sizes.

---

## 4. Script Breakdown & Usage Cases

### VNPlayerHandlers.gd (Static Utility Class)
- **Programmer View:** A stateless static class that processes GraphNode dictionary data. It utilizes Godot's RegEx to parse inline tags ({Emotion, Pose, Anim}) and manipulate the VNPlayer node's active UI tree.
- **Designer View:** You don't interact with this directly. However, because of this script, you can type {Happy} Hello! in a Dialogue Node, and the system will automatically strip the tag, swap the speaker's texture, and play a bounce animation.
- **Modularity:** Highly extensible. New animations (e.g., {Dizzy}) can be added to the EMOTION_ANIMATIONS dictionary.

### GameState.gd (Autoload / Singleton)
- **Programmer View:** The central nervous system of the game. Contains properties like money, stats, and lags. Implements execute_command() to parse string commands from the VN tree.
- **Designer View:** Used indirectly via the **Command Node** and **Condition Node**. You can write eward money 50 or Charm >= 10 && !met_mirul, and this script evaluates it natively.
- **Modularity:** Can be expanded with cloud-save integration or encrypted local storage to prevent player save tampering.

### Main.gd (Scene Manager)
- **Programmer View:** Subscribes to EventBus signals (e.g., scene_change_requested, start_minigame). It controls a ColorRect fader and completely purges the scene tree between transitions.
- **Designer View:** Ensures that when you transition from a Minigame back to the VN, or the VN to the Dorm, the screen fades smoothly to black and audio doesn't clip.

### SeMaK Nodes (e.g., ActorNode.gd, DialogueNode.gd)
- **Programmer View:** Editor-only @tool scripts that inherit from GraphNode. They serialize their customized UI inputs into a get_node_data() dictionary.
- **Designer View:** This is your primary workspace. Drop a Character Profile into an Actor Node to spawn them, or use a Choice Branch node to lock dialogue options behind Stat checks.
- **Modularity:** Adding a new node type requires duplicating a base node, registering it in VNTreeWorkspace, and creating a static builder in VNTreeInspectorBuilders.gd.

---

## 5. Build Creation & Release Pipeline
- **Continuous Integration (CI):** GitHub Actions is configured to trigger builds on pull requests to master.
- **Pipeline:** 
  1. Automated GDScript syntax checking.
  2. Asset validation.
  3. Godot Headless Export targeting PC (Windows/Linux/Mac) and optionally Android for mobile testing.
- **Acceptance Criteria:** A build is marked Release Candidate (RC) only if the UI scales correctly on test resolutions and background transitions occur without stuttering.

---

## 6. Resource Management & File Formats

### Asset Pipeline for 2D VN Aesthetics
- **2D Sprites:** Exported as high-resolution .png files. Character art utilizes Option A (pre-rendered poses and expressions combined) rather than layered paper-dolls to simplify the rendering pipeline.
- **Audio:** .ogg for streaming Background Music (BGM). .wav for immediate UI sound effects (blips, clicks).
- **Data Files:** .tres for engine-native resources (Trees, Profiles). .json for volatile save states.

---

## 7. Tool Instructions

### SeMaK Visual Novel Editor
1. **Access:** Open Godot, click the "VN Tree Editor" tab at the bottom.
2. **Editing:** Right-click the grid to add nodes (Start, Dialogue, Actor, Command, Condition).
3. **Inline Tagging:** In any Dialogue text box, type {player} to auto-inject the player's name. Type {Angry, HandsHips, shake} to dynamically swap the talking character's expression and pose, while triggering a shake animation.
4. **Saving:** Click the "Save Tree" button at the top left of the workspace.

### Minigame Creation Workflow
1. Create a new standard Godot Scene (e.g., ClickerGame.tscn).
2. Build the game using standard nodes. 
3. When the win/loss state is calculated, emit the global signal: EventBus.minigame_completed.emit(true).
4. Call queue_free() on the root node of the minigame.
5. Inside the SeMaK editor, use a Command Node and type: minigame play res://minigames/ClickerGame.tscn. The engine will handle the rest.