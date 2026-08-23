with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('regex.compile("\{([A-Za-z0-9_]+)\}")', 'regex.compile("\\\\{([A-Za-z0-9_]+)\\\\}")')

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\runtime\VNPlayerHandlers.gd', 'w', encoding='utf-8') as f:
    f.write(text)
