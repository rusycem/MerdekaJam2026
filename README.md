# SeMaK VN Designer Manual
Welcome to SeMaK, the robust node-based Visual Novel editor built specifically for MerdekaJam 2026. This document explains every tool, node, tag, and logic feature available to you. For more comprehensive implementation, refer [Technical Design Document (TDD)](Technical_Design_Document_Comprehensive.md) for architecture details.


## 1. Opening the Workspace
To start editing or building a VN Tree:
1. Open Godot.
2. At the bottom panel of the editor, look for the **"VN Tree Editor"** tab. Click it.
3. This opens a visual node workspace. You can **drag and drop .tres files** from the 
es://scenes/StoryScene/ folder into this workspace to edit them, or click "New Tree" to start a fresh chapter.
4. **Important**: Always remember to save the tree when you are done by pressing **Save Tree**.

## 2. Character Setup (Profiles & Audio)
Every character must have a .tres Profile (e.g., Mirul.tres) defining their name and portraits.
- **Portraits Dictionary:** Here, map strings like Happy or HandsHips_Angry to textures. These strings are used dynamically in the VN tree.
- **{player} Name:** If you want a character to inherit the dynamic player name (e.g., "Irfaan"), type {player} in the Character Name property.
- **Blip Pitch:** A float (e.g. 1.2) that automatically changes the procedural pitch of the typewriter typing noise for this character. Smaller numbers are deeper; larger numbers are higher pitched.

## 3. The Node Library
Right-click anywhere in the VN Workspace to spawn a node. Connect nodes by dragging wires from the colored pins on the right to the pins on the left. Execution flows Left to Right.

### Start Node
- **Purpose:** Every tree must have exactly ONE Start Node. The execution begins here when the chapter loads.

### Scene Event Node (Actor/Backgrounds)
- **Purpose:** Controls what is visible on the screen. Click + Add Scene Event to stack multiple visual actions at once before execution continues to the next node.
- **Show Character:** Drag in a Character Profile (.tres). You can set an initial Expression/Pose (e.g., Neutral), define which Slot they spawn in (e.g., Left, Center, Right), define an entrance Animation (e.g., Fade In, Jump, Shake) and set its duration.
- **Hide Character:** Despawns a character. Just type the character's name (e.g., Alyssa).
- **Change Background:** Drag in a .png or .jpg background image. The system will automatically perform a smooth crossfade if another background is currently visible.

### Dialogue Node
- **Purpose:** Where the storytelling happens.
- **Speaker:** Type the character's name (e.g., Alyssa). The system will automatically link this dialogue to Alyssa's sprite on the stage. You can also type {player}.
- **Dialogue Text:** What they say. You can use Tags here (see Section 4).
- **Voice Audio UID (Optional):** Drag an audio file into this slot. If provided, the typewriter beep is muted, and the full voice line is played instead.
- **Grants Flags:** (Optional) Enter a comma-separated list of flags (e.g., met_mirul, knows_secret) to grant them instantly after this line is read.

### Choice Branch Node
- **Purpose:** Prompts the player to make a decision.
- **Prompt:** Text showing at the top of the choice menu (e.g., "Who should I sit with?").
- **Choices:** Click + Add Choice to add routes. 
  - Each choice creates a new output pin.
  - **Required Flag(s):** (Optional) The player can only click this option if they pass the condition (see Section 5).
  - **Hide if Locked:** Check this if you want the option completely hidden when locked. If unchecked, it shows as grayed-out.

### DnD Check Node
- **Purpose:** Triggers a 20-sided dice roll based on the player's stats (Charm, Intelligence, Courage, Dexterity).
- **Target Stat & DC Value:** The stat to roll + modify, and the Target Number to beat (e.g., Courage DC 12).
- **Output Pins:** Success and Failure.

### Condition Node
- **Purpose:** Branch the story invisibly without a player choice.
- **Condition Expression:** Write a logic statement (e.g., money >= 50 && has_ticket). See Section 5.
- **Output Pins:** True and False.

### Command Node
- **Purpose:** Run background actions (modifying money, stats, minigames, changing music).
- **Command String:** See Section 6 for full commands.

### Comment Box
- **Purpose:** Organization. Wrap this box around nodes and color-code it so your VN tree is readable.

---

## 4. Powerful Dialogue Text Tags
You can type powerful tags directly into the Dialogue Node text box to automate mechanics.

### 1. Name Injection
Any time you write {player} inside the dialogue, it will be automatically replaced with the player's actual name. Example: *"Nice to meet you, {player}!"*

### 2. Emotion & Pose Tags
You can dynamically trigger animations and portrait swaps *mid-dialogue* without needing to create new Scene Event nodes. 
**Syntax:** {Emotion, Pose, Animation}
- **Auto-Linking:** Because the Dialogue node knows who the speaker is, it automatically finds their sprite on the stage and animates *only* them.
- **Defaults:** If you don't type a Pose or Animation, it keeps their current pose and plays an automatic built-in animation (Happy -> bounce, Angry -> shake, Surprised -> jump, Sad -> sink, Annoyed -> twitch).

**Examples:**
- {Happy} Yay! -> (Swaps to Happy portrait, keeps current pose, auto-bounces)
- {Angry, HandsHips} No way! -> (Swaps to HandsHips_Angry portrait, auto-shakes)
- {, , jump} Wait! -> (Keeps current emotion and pose, but forces a jump animation)

---

## 5. Logic: Conditions and Flags
Whenever you see a **Condition** field (in a Condition Node or a Choice Option), you can use powerful logic.
- **Flags:** Type a flag name to check if it exists: met_mirul
- **NOT:** Put ! before a flag to check if they DON'T have it: !met_mirul
- **Stats:** Charm >= 10, Money < 50, Courage == 5
- **AND / OR:** Combine conditions with && (AND) or || (OR).
  - Example: Charm >= 10 && !met_mirul
- **Minigames:** minigame_won or minigame_lost (checks the result of the last played minigame).

---

## 6. Command Library
In the **Command Node**, type these exact strings to trigger game events:

### Currency & Stats
- reward money [amount] (e.g. reward money 50 or reward money -20)
- stat [StatName] [amount] (e.g. stat Charm 2 or stat Courage -1)
- flag add [flag_name]
- flag remove [flag_name]

### Game Flow
- add_turns [amount] -> Adds to the player's available Hub/Dorm turns.
- set_next_chapter [uid] -> When this VN tree ends and the player returns to the Hub, this chapter will be automatically queued. To get the [uid], right click a .tres file in the FileSystem dock, select "Copy UID", and paste it here.

### Audio (BGM)
- bgm play [uid] -> Stops the current track and fades in the new music. (Copy the UID of an .mp3/.ogg file from the FileSystem).
- bgm stop -> Fades out the currently playing music. Music perfectly persists across different VN trees until you run this.

### Engine Minigames
- minigame play [name] -> Temporarily suspends the VN player, launches a custom Godot minigame scene, and resumes the VN tree once the minigame returns a win/loss result.
