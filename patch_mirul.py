import sys

def patch_file(path, replaces):
    with open(path, 'r', encoding='utf-8') as f:
        text = f.read()
    for o, n in replaces:
        text = text.replace(o, n)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(text)

patch_file(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\scenes\StoryScene\mirul\level1_test.tres', [
    ('What are you looking at, {player}?', '{Angry} What are you looking at, {player}?'),
    ('Hmph. Weak.', '{Annoyed} Hmph. Weak.'),
    ('Heh. You', '{Happy} Heh. You'),
    ('Watch your mouth, {player}.', '{Angry} Watch your mouth, {player}.'),
    ('You', '{Happy} You')
])

patch_file(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\scenes\StoryScene\mirul\level2_test.tres', [
    ('Hey {player}. You', '{Happy} Hey {player}. You'),
    ('Hey {player}. I', '{Angry} Hey {player}. I'),
    ('Thanks. Let', '{Happy} Thanks. Let'),
    ('Figures. Guess we', '{Sad} Figures. Guess we'),
    ('Alright, break time is over.', '{Neutral} Alright, break time is over.'),
    ('I feel a bit better about the exams.', '{Happy} I feel a bit better about the exams.')
])

patch_file(r'd:\GodotProjects\merdeka-jam\MerdekaJam2026\scenes\StoryScene\mirul\level3_test.tres', [
    ('This is it, {player}. The final exam.', '{Surprised} This is it, {player}. The final exam.'),
    ('Wow! I actually passed! Thanks to you, {player}.', '{Happy} Wow! I actually passed! Thanks to you, {player}.'),
    ('Damn... I failed. But it', '{Sad} Damn... I failed. But it')
])
