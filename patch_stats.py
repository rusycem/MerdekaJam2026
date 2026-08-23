with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\addons\semak\core\vn_tree_inspector_builders.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('var stats = ["STR", "DEX", "CON", "INT", "WIS", "CHA"]', 'var stats = ["Charm", "Intelligence", "Courage", "Dexterity"]')

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\addons\semak\core\vn_tree_inspector_builders.gd', 'w', encoding='utf-8') as f:
    f.write(text)
