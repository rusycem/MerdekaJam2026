# Technical Design Document (TDD)
**Project Name:** SeMaK - MerdekaJam 2026  
**Engine:** Godot 4.3 (GDScript / C++ GDExtension)  
**Genre:** Visual Novel / RPG Hybrid (VR Implementation)

---

## 1. Introduction

### Technical Goals & Purpose
The objective of this project is to create a modular, scalable Visual Novel/RPG hybrid using Godot. The core technical mandate is the implementation of **SeMaK**, a custom node-based visual scripting editor built directly into the Godot Editor. This ensures Game Designers can build complex branching logic, emotional state changes, and stat checks without requiring engineering support.

### Target Platform: Meta Quest 3
While the engine supports standalone PC builds, this TDD specifically targets deployment constraints for the **Meta Quest 3 (Android/VR)** environment. 
- **Hardware Profile:** Snapdragon XR2 Gen 2, 8GB RAM.
- **Rendering Backend:** Vulkan Mobile (Forward+ is too expensive for standalone VR).
- **Foveated Rendering:** Enabled (Fixed Foveated Rendering level 2-3).
- **Refresh Rate:** Locked at 90Hz minimum to prevent VR sickness.

### Branch Policy (Git Flow)
- `master` / `main`: Stable production builds. Only updated via pull requests from `develop`.
- `develop`: Main integration branch. All features merge here.
- `feature/[name]`: Active development branches for new mechanics.
- `release/[version]`: Final stabilization branch for a milestone build.
- `hotfix/[name]`: Emergency patching for the `main` branch.

---

## 2. Technical Overview

### Naming Conventions & Coding Standards
- **GDScript (Classes/Nodes):** `PascalCase` (e.g., `CharacterProfile.gd`, `VNPlayerHandlers.gd`).
- **GDScript (Variables/Functions):** `snake_case` (e.g., `current_node_id`, `handle_dialogue()`).
- **C++ GDExtension (Future/Optimization):** `PascalCase` for classes, `snake_case` for methods. Variables prefixed with `m_` (e.g., `m_health`).
- **Assets:** `snake_case` (e.g., `mirul_happy.png`, `bg_dorm_night.jpg`).

### Data Layout
Player state and campaign progression are strictly isolated to ensure deterministic save/loads.
- **Runtime State:** Encapsulated entirely in the `GameState.gd` Autoload. It stores arrays of strings (flags), dictionaries (stats), and integers (currency, turns).
- **Save States:** Handled by `SaveManager.gd`. The `GameState` is serialized via `JSON.stringify()` and written to `user://saves/[slot].json`. 
- **Volatile State:** Scene-specific data (e.g., current VN dialogue index, UI animation tweens) are dropped completely when moving between the Hub and VN scenes to prevent memory leaks.

### Performance Budgets (90Hz VR Target)
To maintain 90 frames per second on Quest 3, the total frame time must not exceed **11.1ms**.
- **Graphics / Rendering:** ~7.0ms (UI pass, 3D environment rendering, foveated rendering overhead).
- **Game Logic (GDScript):** ~2.0ms (VN node parsing, regex string matching, state updates).
- **Audio:** ~1.0ms (Procedural sine-wave blip generation, BGM streaming).
- **Overhead/System:** ~1.1ms.

---

## 3. Game Mechanics & Architecture

### Core Game Loop
1. **Main Menu:** Loads save data via `SaveManager`.
2. **Dorm (Hub):** A time-management state. Players spend 'Turns' to trigger specific Story Chapters.
3. **VN Engine:** `Main.gd` loads `VNPlayer.tscn`. The engine parses the selected `VNStoryTree` (a custom Resource) and executes dialogue, stat checks, and background animations.
4. **Minigame Interruption:** A Command Node can pause the VN tree and push a Minigame scene onto the active tree. The Minigame resolves, emits an `EventBus` signal, and control is returned to the VN Engine.

### Primary Game Structures (Data-Oriented Approach)
- **Entities:** Instead of deep inheritance trees, characters are defined by lightweight `CharacterProfile` Resources that map strings (emotions) to textures or 3D meshes.
- **Levels:** `Main.gd` acts as a root SceneManager. It clears its `LevelContainer` and `MenuContainer` before instantiating new scenes to ensure absolute memory isolation.
- **UI:** Managed via a global Theme (`.tres`). Dialogue panels and VR canvases use floating `SubViewport` nodes projected onto 3D `QuadMeshes` for Quest 3 compatibility.

---

## 4. Script Breakdown & Usage Cases

### `VNPlayerHandlers.gd` (Static Utility Class)
- **Programmer View:** A stateless static class that processes `GraphNode` dictionary data. It utilizes Godot's `RegEx` to parse inline tags (`{Emotion, Pose, Anim}`) and manipulate the `VNPlayer` node's active UI tree.
- **Designer View:** You don't interact with this directly. However, because of this script, you can type `{Happy} Hello!` in a Dialogue Node, and the system will automatically strip the tag, swap the speaker's texture, and play a bounce animation.
- **Modularity:** Highly extensible. New animations (e.g., `{Dizzy}`) can be added to the `EMOTION_ANIMATIONS` dictionary. C++ GDExtension could be used here to pre-compile the RegEx patterns if dialogue parsing becomes a bottleneck in VR.

### `GameState.gd` (Autoload / Singleton)
- **Programmer View:** The central nervous system of the game. Contains properties like `money`, `stats`, and `flags`. Implements `execute_command()` to parse string commands from the VN tree.
- **Designer View:** Used indirectly via the **Command Node** and **Condition Node**. You can write `reward money 50` or `Charm >= 10 && !met_mirul`, and this script evaluates it natively.
- **Modularity:** Can be expanded into a C++ module for ultra-fast binary serialization or cloud-save encryption. 

### `Main.gd` (Scene Manager)
- **Programmer View:** Subscribes to `EventBus` signals (e.g., `scene_change_requested`, `start_minigame`). It controls a `ColorRect` fader and completely purges the scene tree between transitions.
- **Designer View:** Ensures that when you transition from a Minigame back to the VN, or the VN to the Dorm, the screen fades smoothly to black and audio doesn't clip.
- **Modularity:** Could be expanded to support asynchronous background loading (`ResourceLoader.load_threaded_request`) for heavy VR 3D environments.

### `SeMaK` Nodes (e.g., `ActorNode.gd`, `DialogueNode.gd`)
- **Programmer View:** Editor-only `@tool` scripts that inherit from `GraphNode`. They serialize their customized UI inputs into a `get_node_data()` dictionary.
- **Designer View:** This is your primary workspace. Drop a Character Profile into an Actor Node to spawn them, or use a Choice Branch node to lock dialogue options behind Stat checks.
- **Modularity:** Adding a new node type requires duplicating a base node, registering it in `VNTreeWorkspace`, and creating a static builder in `VNTreeInspectorBuilders.gd`.

---

## 5. Build Creation & Release Pipeline
- **Continuous Integration (CI):** GitHub Actions is configured to trigger builds on pull requests to `master`.
- **Pipeline:** 
  1. Automated GDScript syntax checking.
  2. Asset validation (ensuring no uncompressed audio/textures exceed VR budgets).
  3. Godot Headless Export targeting `Android` (APK for Quest) and `Windows` (for developer testing).
- **Acceptance Criteria:** A build is marked Release Candidate (RC) only if it maintains a solid 90 FPS on target hardware without frame drops during background crossfades or minigame instantiation.

---

## 6. Resource Management & File Formats

### Asset Pipeline for VR RPG Aesthetics
The visual identity demands **"blending blocky, sculptural anime facial topology with hand-painted PBR textures."**
- **3D Models:** Exported as `.glb` (glTF 2.0). Faces must use explicit custom normals to achieve the blocky sculptural anime shading, while materials must utilize Godot's StandardMaterial3D configured for Unshaded or custom Toon shaders.
- **Textures:** Hand-painted PBR textures must be saved as `.png` (lossless for UI) or `.webp` / `. basis` (VRAM compressed for 3D surfaces). 
  - *Max Texture Size:* 2048x2048 for main character atlases. 512x512 for standard props.
- **Audio:** `.ogg` for streaming Background Music (BGM). `.wav` for immediate UI sound effects (blips, clicks).
- **Data Files:** `.tres` for engine-native resources (Trees, Profiles). `.json` for volatile save states.

---

## 7. Tool Instructions

### SeMaK Visual Novel Editor
1. **Access:** Open Godot, click the "VN Tree Editor" tab at the bottom.
2. **Editing:** Right-click the grid to add nodes (Start, Dialogue, Actor, Command, Condition).
3. **Inline Tagging:** In any Dialogue text box, type `{player}` to auto-inject the player's name. Type `{Angry, HandsHips, shake}` to dynamically swap the talking character's expression and pose, while triggering a shake animation.
4. **Saving:** Click the "Save Tree" button at the top left of the workspace.

### Minigame Creation Workflow
1. Create a new standard Godot Scene (e.g., `ClickerGame.tscn`).
2. Build the game using standard nodes. 
3. When the win/loss state is calculated, emit the global signal: `EventBus.minigame_completed.emit(true)`.
4. Call `queue_free()` on the root node of the minigame.
5. Inside the SeMaK editor, use a Command Node and type: `minigame play res://minigames/ClickerGame.tscn`. The engine will handle the rest.
