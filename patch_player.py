with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('var char_name = ev.get("character", "Unknown").to_lower()', 'var char_name = ev.get("character", "Unknown").replace("{player}", GameState.player_name).to_lower()')

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'w', encoding='utf-8') as f:
    f.write(text)
