with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\scenes\StoryScene\prologue_test.tres', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace('{player}! I see', '{Happy} {player}! I see')
text = text.replace('Ohh great', '{Happy} Ohh great')
text = text.replace('Welcome to school', '{Happy} Welcome to school')
text = text.replace('... (He ignores', '{Annoyed} ... (He ignores')
text = text.replace('I see you have met my son', '{Happy} I see you have met my son')
text = text.replace('Whatever, {player}', '{Angry} Whatever, {player}')
text = text.replace('You... you beat my', '{Surprised} You... you beat my')
text = text.replace('Vihaan is a bit quiet', '{Happy} Vihaan is a bit quiet')
text = text.replace('Phew, that training', '{Happy} Phew, that training')

with open(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\scenes\StoryScene\prologue_test.tres', 'w', encoding='utf-8') as f:
    f.write(text)
