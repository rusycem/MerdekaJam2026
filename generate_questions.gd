extends SceneTree

func _init() -> void:
	print("Generating ErrorHuntData.gd with 205+ questions...")
	
	var questions: Array[Dictionary] = []
	
	# ==========================================
	# 1. WORD TAP QUESTIONS (80 Questions: 8 per category)
	# ==========================================
	
	# 1.1 Verb Tense
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["She", "go", "to", "school", "yesterday."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["Aina", "finish", "her", "homework", "last", "night."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["We", "watch", "a", "football", "match", "last", "weekend."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["He", "see", "the", "headmaster", "ten", "minutes", "ago."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["The", "teacher", "write", "the", "notes", "on", "the", "board", "earlier."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["They", "eats", "lunch", "at", "the", "canteen", "yesterday."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["Vihaan", "has", "spoke", "to", "the", "counselor", "already."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["Yesterday,", "Alyssa", "run", "five", "laps", "around", "the", "track."], "correct_index": 2})

	# 1.2 Subject-Verb Agreement
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["He", "play", "football", "every", "single", "evening."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["The", "students", "is", "studying", "diligently", "in", "the", "hall."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["Every", "student", "have", "a", "locker", "key."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["The", "school", "prefects", "walks", "around", "the", "block."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["Mirul", "and", "Alyssa", "is", "attending", "the", "meeting."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["She", "don't", "like", "eating", "spicy", "food."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["A", "bouquet", "of", "yellow", "flowers", "were", "delivered."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Subject-Verb Agreement", "words": ["The", "quality", "of", "these", "mangos", "are", "exceptional."], "correct_index": 5})

	# 1.3 Singular / Plural
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["There", "are", "three", "book", "on", "the", "table."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["The", "teacher", "gave", "us", "many", "homeworks", "today."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["I", "saw", "two", "cat", "sleeping", "outside", "the", "dorm."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["Several", "student", "arrived", "late", "for", "morning", "assembly."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["She", "bought", "five", "apple", "from", "the", "stall."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["Both", "boy", "participated", "in", "the", "annual", "tournament."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["We", "packed", "all", "our", "furnitures", "into", "the", "van."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Singular / Plural", "words": ["The", "sheep", "ran", "across", "the", "green", "valleys."], "correct_index": 1}) # error swap: The sheeps ran
	questions[questions.size() - 1]["words"] = ["The", "sheeps", "ran", "across", "the", "green", "meadow."]

	# 1.4 Article
	questions.append({"type": "word_tap", "category": "Article", "words": ["She", "bought", "a", "umbrella", "during", "the", "heavy", "storm."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Article", "words": ["He", "is", "a", "honest", "boy", "in", "our", "school."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Article", "words": ["I", "waited", "for", "a", "hour", "at", "the", "entrance."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Article", "words": ["Please", "pass", "me", "an", "pencil", "from", "your", "case."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Article", "words": ["She", "dreams", "to", "become", "an", "doctor", "one", "day."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Article", "words": ["Vihaan", "found", "a", "old", "coin", "near", "the", "canteen."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Article", "words": ["They", "saw", "an", "unicorn", "in", "the", "storybook."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Article", "words": ["This", "is", "an", "useful", "guide", "for", "Form", "3."], "correct_index": 2})

	# 1.5 Pronoun
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Sarah", "forgot", "his", "bag", "in", "the", "classroom."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["The", "cat", "licked", "it's", "fur", "very", "calmly."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["The", "boys", "said", "that", "her", "project", "was", "ready."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Please", "give", "the", "science", "textbook", "to", "I."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Alyssa", "said", "that", "he", "will", "join", "our", "group."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Between", "you", "and", "I,", "this", "quiz", "is", "tricky."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Each", "of", "the", "girls", "brought", "their", "own", "ruler."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Him", "and", "Mirul", "are", "training", "for", "SPM", "sports."], "correct_index": 0})

	# 1.6 Preposition
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["He", "arrived", "in", "school", "at", "7", "AM."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["She", "is", "exceptionally", "good", "in", "mathematics."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["The", "class", "meeting", "starts", "on", "2", "PM."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["I", "am", "keenly", "interested", "with", "learning", "biology."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["We", "traveled", "to", "the", "library", "by", "foot."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["She", "was", "falsely", "accused", "for", "cheating."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["We", "discussed", "about", "the", "history", "syllabus", "together."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["He", "congratulated", "me", "for", "winning", "the", "essay", "prize."], "correct_index": 3})

	# 1.7 Spelling
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["The", "view", "from", "the", "dorm", "was", "beautifull."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["He", "made", "a", "careless", "misstake", "on", "the", "test."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["The", "library", "is", "peacefull", "during", "exam", "week."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["We", "will", "receive", "our", "report", "cards", "tomorow."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["Studying", "every", "day", "is", "neccessary", "for", "success."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["He", "felt", "deep", "embarassment", "in", "front", "of", "class."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["Please", "seperate", "the", "recycle", "bins", "by", "color."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["I", "definately", "want", "to", "score", "straight", "A's."], "correct_index": 1})

	# 1.8 Capitalization
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["we", "went", "home", "after", "the", "curriculum", "club."], "correct_index": 0})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["They", "visited", "kuala", "Lumpur", "during", "the", "break."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["On", "monday,", "the", "school", "holds", "the", "assembly."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["My", "friend", "speaks", "english", "and", "Malay", "fluently."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["The", "merdeka", "celebration", "takes", "place", "in", "August."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["We", "have", "science", "revision", "every", "tuesday", "afternoon."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["Our", "class", "will", "visit", "penang", "next", "month."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["The", "principal", "introduced", "mr.", "Tan", "as", "our", "teacher."], "correct_index": 3})

	# 1.9 Punctuation
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["Where", "are", "you", "going.", "to", "study", "tonight?"], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["What", "time", "does", "the", "school", "canteen", "open."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["How", "did", "you", "solve", "this", "algebra", "equation."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["Why", "is", "the", "chemistry", "laboratory", "locked."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["Could", "you", "lend", "me", "your", "blue", "pen."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["Where", "did", "Mirul", "buy", "that", "cool", "calculator."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["Watch", "out.", "The", "floor", "is", "extremely", "slippery!"], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Punctuation", "words": ["Who", "is", "responsible", "for", "cleaning", "the", "whiteboard."], "correct_index": 6})

	# 1.10 Word Choice
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["I", "borrowed", "him", "my", "favorite", "fountain", "pen."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["She", "told", "that", "she", "was", "prepared", "for", "exams."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["He", "did", "a", "grave", "mistake", "during", "the", "debate."], "correct_index": 1})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["The", "new", "schedule", "had", "no", "affect", "on", "us."], "correct_index": 5})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["Please", "listen", "attentively", "to", "my", "valuable", "advise."], "correct_index": 6})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["The", "principal", "will", "accept", "no", "excuses", "for", "being", "lose."], "correct_index": 8})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["The", "hot", "sun", "will", "compliment", "our", "outdoor", "game."], "correct_index": 4})
	questions.append({"type": "word_tap", "category": "Word Choice", "words": ["We", "have", "fewer", "water", "left", "in", "our", "canteen", "bottles."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Verb Tense", "words": ["She", "has", "drank", "all", "the", "iced", "milo."], "correct_index": 2})
	questions.append({"type": "word_tap", "category": "Preposition", "words": ["He", "is", "sitting", "in", "the", "front", "bench."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Article", "words": ["Alyssa", "wears", "a", "unique", "silver", "badge."], "correct_index": 2}) # unique has 'yu' sound so 'a' is correct; let's do: wears an unique
	questions[questions.size() - 1]["words"] = ["Alyssa", "wears", "an", "unique", "silver", "school", "badge."]
	questions[questions.size() - 1]["correct_index"] = 2
	questions.append({"type": "word_tap", "category": "Pronoun", "words": ["Her", "and", "Mirul", "studied", "at", "the", "dorm."], "correct_index": 0})
	questions.append({"type": "word_tap", "category": "Spelling", "words": ["That", "was", "a", "truely", "magnificent", "speech."], "correct_index": 3})
	questions.append({"type": "word_tap", "category": "Capitalization", "words": ["Our", "headmaster", "speaks", "fluent", "mandarin.", "today."], "correct_index": 4})

	# ==========================================
	# 2. MCQ ERROR IDENTIFICATION (45 Questions)
	# ==========================================
	var mcq_err_raw = [
		{"s": "She don't know the answer to question 5.", "opts": ["She", "don't", "the answer", "question 5"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "The team have won their first championship match.", "opts": ["The team", "have won", "their first", "match"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "Neither of the boys were present at the meeting.", "opts": ["Neither", "of the boys", "were present", "at the meeting"], "ans": 2, "c": "Subject-Verb Agreement"},
		{"s": "There is many reasons why we should study early.", "opts": ["There is", "many reasons", "why we should", "study early"], "ans": 0, "c": "Subject-Verb Agreement"},
		{"s": "Each of the participants receive a certificate of attendance.", "opts": ["Each of", "the participants", "receive", "a certificate"], "ans": 2, "c": "Subject-Verb Agreement"},
		{"s": "Physics are my favorite subject in school.", "opts": ["Physics", "are", "my favorite", "in school"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "The news about the exam were shocking to everyone.", "opts": ["The news", "about the exam", "were", "shocking to everyone"], "ans": 2, "c": "Subject-Verb Agreement"},
		{"s": "Ten kilometers are a long distance to walk.", "opts": ["Ten kilometers", "are", "a long distance", "to walk"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "Bread and butter are his usual breakfast choice.", "opts": ["Bread and butter", "are", "his usual", "breakfast choice"], "ans": 1, "c": "Subject-Verb Agreement"},

		{"s": "He has went to the bookstore to buy revision books.", "opts": ["He", "has went", "to the bookstore", "to buy"], "ans": 1, "c": "Verb Tense"},
		{"s": "When I reached home, my sister already slept.", "opts": ["When I reached", "home", "already slept", "yesterday"], "ans": 2, "c": "Verb Tense"},
		{"s": "They have began the science experiment without supervision.", "opts": ["They", "have began", "the science experiment", "without supervision"], "ans": 1, "c": "Verb Tense"},
		{"s": "She did not knew the password to log in.", "opts": ["She", "did not", "knew", "the password"], "ans": 2, "c": "Verb Tense"},
		{"s": "Last night I dreamed that I fly across the sky.", "opts": ["Last night", "I dreamed", "that I fly", "across the sky"], "ans": 2, "c": "Verb Tense"},
		{"s": "By next month, we will completed Form 3.", "opts": ["By next month", "we will", "completed", "Form 3"], "ans": 2, "c": "Verb Tense"},
		{"s": "The bell had rang before we entered the hall.", "opts": ["The bell", "had rang", "before we", "entered"], "ans": 1, "c": "Verb Tense"},
		{"s": "He would has helped you if you had asked him.", "opts": ["He would", "has helped", "if you", "had asked"], "ans": 1, "c": "Verb Tense"},

		{"s": "She gave me an useful piece of advice yesterday.", "opts": ["She gave me", "an useful", "piece of advice", "yesterday"], "ans": 1, "c": "Article"},
		{"s": "He is a heir to a large historical library.", "opts": ["He is", "a heir", "to a large", "historical library"], "ans": 1, "c": "Article"},
		{"s": "It was an one-hour revision session before the exam.", "opts": ["It was", "an one-hour", "revision session", "before the exam"], "ans": 1, "c": "Article"},
		{"s": "We need to hire a electrician to fix the dorm lights.", "opts": ["We need", "to hire", "a electrician", "to fix the lights"], "ans": 2, "c": "Article"},
		{"s": "She found an European coin inside her pencil case.", "opts": ["She found", "an European", "coin inside", "her pencil case"], "ans": 1, "c": "Article"},

		{"s": "Me and my tablemate completed the project on time.", "opts": ["Me and", "my tablemate", "completed", "on time"], "ans": 0, "c": "Pronoun"},
		{"s": "The teacher told Mirul and I to collect the workbooks.", "opts": ["The teacher", "told", "Mirul and I", "to collect"], "ans": 2, "c": "Pronoun"},
		{"s": "Everyone must bring their own compass to mathematics.", "opts": ["Everyone", "must bring", "their own", "to mathematics"], "ans": 2, "c": "Pronoun"},
		{"s": "Whom is knocking on the staffroom door?", "opts": ["Whom", "is knocking", "on the", "staffroom door"], "ans": 0, "c": "Pronoun"},
		{"s": "The dog wagged it's tail when it saw the student.", "opts": ["The dog", "wagged", "it's tail", "when it saw"], "ans": 2, "c": "Pronoun"},

		{"s": "He is very skilled on playing the acoustic guitar.", "opts": ["He is", "very skilled", "on playing", "the acoustic guitar"], "ans": 2, "c": "Preposition"},
		{"s": "She congratulated me for getting the highest marks.", "opts": ["She", "congratulated me", "for getting", "the highest marks"], "ans": 2, "c": "Preposition"},
		{"s": "We are looking forward to meet the new principal.", "opts": ["We are", "looking forward", "to meet", "the new principal"], "ans": 2, "c": "Preposition"},
		{"s": "I prefer studying in the morning than studying at night.", "opts": ["I prefer", "studying in morning", "than studying", "at night"], "ans": 2, "c": "Preposition"},
		{"s": "He died from malaria while on a research trip.", "opts": ["He died", "from malaria", "while on", "a research trip"], "ans": 1, "c": "Preposition"},

		{"s": "The student was totally unware of the upcoming quiz.", "opts": ["The student", "was totally", "unware", "of the quiz"], "ans": 2, "c": "Spelling"},
		{"s": "Our school has a strict policie regarding mobile phones.", "opts": ["Our school", "has a strict", "policie", "regarding phones"], "ans": 2, "c": "Spelling"},
		{"s": "He wrote a very intresting paragraph in his essay.", "opts": ["He wrote", "a very", "intresting", "paragraph"], "ans": 2, "c": "Spelling"},
		{"s": "Success requires great discipline and perseverence.", "opts": ["Success requires", "great discipline", "and", "perseverence"], "ans": 3, "c": "Spelling"},
		{"s": "The hostel warden gave us a clear explaination.", "opts": ["The hostel warden", "gave us", "a clear", "explaination"], "ans": 3, "c": "Spelling"},

		{"s": "Can you lend me your dictionary, I left mine at home.", "opts": ["Can you lend", "your dictionary,", "I left mine", "at home"], "ans": 1, "c": "Punctuation"},
		{"s": "Tell me where did you hide the library keys.", "opts": ["Tell me", "where did", "you hide", "the library keys."], "ans": 1, "c": "Word Order / Punctuation"},
		{"s": "The principal gave an inspiring, speech to the students.", "opts": ["The principal", "gave an", "inspiring,", "speech to students"], "ans": 2, "c": "Punctuation"},

		{"s": "His grades will loose him a chance at the scholarship.", "opts": ["His grades", "will loose", "him a chance", "at scholarship"], "ans": 1, "c": "Word Choice"},
		{"s": "She poured the hot water into the glass stationary.", "opts": ["She poured", "the hot water", "into the", "glass stationary"], "ans": 3, "c": "Word Choice"},
		{"s": "The medicine had no noticeable side affects on him.", "opts": ["The medicine", "had no", "noticeable", "side affects"], "ans": 3, "c": "Word Choice"},
		{"s": "He is the principle dancer in the cultural club.", "opts": ["He is", "the principle", "dancer in", "cultural club"], "ans": 1, "c": "Word Choice"},
		{"s": "The weather today will complement our sports activities.", "opts": ["The weather", "will complement", "our sports", "activities"], "ans": 1, "c": "Word Choice"}
	]
	
	for item in mcq_err_raw:
		questions.append({
			"type": "mcq_error",
			"category": item["c"],
			"prompt": "Identify the option with the grammatical error:",
			"sentence": item["s"],
			"options": item["opts"],
			"correct_index": item["ans"]
		})

	# ==========================================
	# 3. CORRECTION & FILL-IN-THE-BLANK (45 Questions)
	# ==========================================
	var mcq_fix_raw = [
		{"s": "Neither the teacher nor the students ___ present.", "opts": ["was", "were", "is", "being"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "Every one of the books ___ returned to the library.", "opts": ["have been", "has been", "are", "were"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "The committee ___ decided to postpone the assembly.", "opts": ["have", "has", "are", "were"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "Mathematics ___ my hardest subject this semester.", "opts": ["are", "is", "were", "being"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "A pair of scissors ___ lying on the teacher's table.", "opts": ["are", "is", "were", "have"], "ans": 1, "c": "Subject-Verb Agreement"},
		{"s": "None of the leaked water ___ recovered.", "opts": ["were", "was", "are", "have"], "ans": 1, "c": "Subject-Verb Agreement"},

		{"s": "If I ___ you, I would start revising SPM subjects now.", "opts": ["was", "were", "am", "have been"], "ans": 1, "c": "Subjunctive / Tense"},
		{"s": "She ___ for three hours before she finally took a break.", "opts": ["has studied", "had been studying", "studies", "is studying"], "ans": 1, "c": "Verb Tense"},
		{"s": "By the time the bell rang, we ___ our test papers.", "opts": ["submit", "had submitted", "have submit", "submitting"], "ans": 1, "c": "Verb Tense"},
		{"s": "He ___ never seen such a difficult math problem before.", "opts": ["has", "had", "was", "having"], "ans": 1, "c": "Verb Tense"},
		{"s": "I wish I ___ more time during the English essay exam.", "opts": ["have", "had", "have had", "am having"], "ans": 1, "c": "Verb Tense"},
		{"s": "The train ___ by the time we reached the station.", "opts": ["left", "had left", "has left", "leaves"], "ans": 1, "c": "Verb Tense"},

		{"s": "He is ___ honest student who never cheats during tests.", "opts": ["a", "an", "the", "no article"], "ans": 1, "c": "Article"},
		{"s": "She has been waiting for ___ hour at the bus terminal.", "opts": ["a", "an", "the", "some"], "ans": 1, "c": "Article"},
		{"s": "This is ___ unique opportunity for all Form 3 students.", "opts": ["an", "a", "the", "some"], "ans": 1, "c": "Article"},
		{"s": "Mount Kinabalu is ___ highest peak in Malaysia.", "opts": ["a", "an", "the", "no article"], "ans": 2, "c": "Article"},
		{"s": "He plays ___ guitar with great skill and emotion.", "opts": ["a", "an", "the", "no article"], "ans": 2, "c": "Article"},

		{"s": "Between you and ___, I think this test is very fair.", "opts": ["I", "me", "myself", "he"], "ans": 1, "c": "Pronoun"},
		{"s": "The girl ___ scored highest was awarded a trophy.", "opts": ["which", "who", "whom", "whose"], "ans": 1, "c": "Pronoun"},
		{"s": "The student with ___ I shared my notes passed the exam.", "opts": ["who", "whom", "which", "whose"], "ans": 1, "c": "Pronoun"},
		{"s": "The dorm room lost ___ electrical power last night.", "opts": ["it's", "its", "their", "it"], "ans": 1, "c": "Pronoun"},
		{"s": "Mirul and ___ were selected for the debate team.", "opts": ["me", "I", "myself", "mine"], "ans": 1, "c": "Pronoun"},

		{"s": "She is accustomed ___ waking up early for boarding school.", "opts": ["with", "to", "for", "at"], "ans": 1, "c": "Preposition"},
		{"s": "He apologized ___ his mistake during the lab experiment.", "opts": ["for", "at", "with", "to"], "ans": 0, "c": "Preposition"},
		{"s": "They succeeded ___ solving the complex chemistry puzzle.", "opts": ["in", "at", "on", "for"], "ans": 0, "c": "Preposition"},
		{"s": "We must comply ___ the boarding school rules.", "opts": ["to", "with", "for", "on"], "ans": 1, "c": "Preposition"},
		{"s": "She is famous ___ her exceptional calligraphy skills.", "opts": ["with", "for", "in", "by"], "ans": 1, "c": "Preposition"},
		{"s": "He is married ___ a high school English teacher.", "opts": ["with", "to", "for", "at"], "ans": 1, "c": "Preposition"},

		{"s": "Which is the correct spelling for 'giving up'?", "opts": ["Surrendar", "Surrender", "Surender", "Surendar"], "ans": 1, "c": "Spelling"},
		{"s": "Which is the correct spelling for 'staying overnight'?", "opts": ["Accomodation", "Accommodation", "Acommodation", "Accomodatoin"], "ans": 1, "c": "Spelling"},
		{"s": "Which is the correct spelling for 'freedom from bias'?", "opts": ["Priviledge", "Privilege", "Privelege", "Privilige"], "ans": 1, "c": "Spelling"},
		{"s": "Which word is spelled correctly?", "opts": ["Mispell", "Misspell", "Mispel", "Mispelll"], "ans": 1, "c": "Spelling"},
		{"s": "Which is the correct spelling for 'a celebration'?", "opts": ["Occasion", "Ocassion", "Occassion", "Occasionn"], "ans": 0, "c": "Spelling"},

		{"s": "The headmaster will not ___ late submissions.", "opts": ["except", "accept", "aspect", "expect"], "ans": 1, "c": "Word Choice"},
		{"s": "His inspirational speech had a positive ___ on the students.", "opts": ["affect", "effect", "effective", "effects"], "ans": 1, "c": "Word Choice"},
		{"s": "Please give me some helpful ___ on how to study for SPM.", "opts": ["advise", "advice", "advicing", "advices"], "ans": 1, "c": "Word Choice"},
		{"s": "The athlete has a ___ knot in his shoelace.", "opts": ["lose", "loose", "lost", "losing"], "ans": 1, "c": "Word Choice"},
		{"s": "She walked ___ the library without making any sound.", "opts": ["passed", "past", "pass", "passing"], "ans": 1, "c": "Word Choice"},
		{"s": "We bought fresh pens and notebooks from the ___ shop.", "opts": ["stationary", "stationery", "station", "stationar"], "ans": 1, "c": "Word Choice"},

		{"s": "There are ___ mistakes in your essay than in mine.", "opts": ["less", "fewer", "lesser", "little"], "ans": 1, "c": "Singular / Plural"},
		{"s": "How ___ homework do we have for tomorrow?", "opts": ["many", "much", "few", "number of"], "ans": 1, "c": "Quantifiers"},
		{"s": "A large ___ of students attended the Merdeka assembly.", "opts": ["amount", "number", "quantity", "deal"], "ans": 1, "c": "Quantifiers"},
		{"s": "She has ___ patience when teaching younger students.", "opts": ["many", "a great deal of", "a number of", "few"], "ans": 1, "c": "Quantifiers"},
		{"s": "The dorm room has very ___ furniture.", "opts": ["few", "little", "many", "small"], "ans": 1, "c": "Quantifiers"}
	]

	for item in mcq_fix_raw:
		questions.append({
			"type": "mcq_fix",
			"category": item["c"],
			"prompt": "Choose the correct option to complete the sentence:",
			"sentence": item["s"],
			"options": item["opts"],
			"correct_index": item["ans"]
		})

	# ==========================================
	# 4. SENTENCE SPOTTER (35 Questions)
	# ==========================================
	var spotter_raw = [
		{"opts": ["She plays badminton every Saturday.", "He go to the market yesterday.", "We enjoy reading storybooks.", "They study in the library."], "ans": 1, "c": "Verb Tense"},
		{"opts": ["The sun rises in the east.", "Water boils at 100 degrees Celsius.", "Cats likes to chase small mice.", "Birds fly high in the sky."], "ans": 2, "c": "Subject-Verb Agreement"},
		{"opts": ["He bought three fresh apples.", "She wrote two long essays.", "I have many homeworks to do.", "They visited four museums."], "ans": 2, "c": "Singular / Plural"},
		{"opts": ["He is an honest prefect.", "She waited for an hour.", "Vihaan found a old textbook.", "They saw a big helicopter."], "ans": 2, "c": "Article"},
		{"opts": ["Sarah forgot her lunchbox.", "The cat cleaned its fur.", "Give the dictionary to me.", "Him and Alyssa are classmates."], "ans": 3, "c": "Pronoun"},
		{"opts": ["She is good at mathematics.", "He arrived at school on time.", "We discussed about the project.", "They are interested in science."], "ans": 2, "c": "Preposition"},
		{"opts": ["The view was beautiful.", "He made a silly misstake.", "The hall was quiet.", "We had a peaceful night."], "ans": 1, "c": "Spelling"},
		{"opts": ["We visited Kuala Lumpur.", "On Monday, we have assembly.", "They speak fluent english.", "August is Merdeka month."], "ans": 2, "c": "Capitalization"},
		{"opts": ["Where are you going?", "What time does class start.", "How did you solve this?", "Why is the door open?"], "ans": 1, "c": "Punctuation"},
		{"opts": ["I lent him my pencil.", "She said she was ready.", "He made a big mistake.", "Lack of sleep had no affect on me."], "ans": 3, "c": "Word Choice"},

		{"opts": ["Neither of the boys was late.", "Each student has a locker.", "The group of teachers are meeting.", "Everybody loves holidays."], "ans": 2, "c": "Subject-Verb Agreement"},
		{"opts": ["The news is very exciting.", "Physics is an interesting subject.", "Ten dollars is enough for lunch.", "The police is investigating the case."], "ans": 3, "c": "Subject-Verb Agreement"},
		{"opts": ["She has finished her test.", "They have eaten their lunch.", "He has broke his glasses.", "We have seen the principal."], "ans": 2, "c": "Verb Tense"},
		{"opts": ["When I arrived, he had left.", "She will come tomorrow.", "He did not saw the warning sign.", "They were playing football."], "ans": 2, "c": "Verb Tense"},
		{"opts": ["An umbrella is very useful.", "He is a European tourist.", "She wants to be a artist.", "This is a one-way street."], "ans": 2, "c": "Article"},

		{"opts": ["Between you and me, he is right.", "Let Mirul and I go to the dorm.", "Who gave you that notebook?", "Whom did you invite?"], "ans": 1, "c": "Pronoun"},
		{"opts": ["She congratulated him on winning.", "He is married to my cousin.", "They accused him for stealing.", "We walked on foot."], "ans": 2, "c": "Preposition"},
		{"opts": ["He is very different from me.", "She is superior to her rivals.", "He is junior than my brother.", "I prefer tea to coffee."], "ans": 2, "c": "Preposition"},
		{"opts": ["It is definitely raining.", "I received the letter.", "We need necessary equipment.", "His embarrasment was obvious."], "ans": 3, "c": "Spelling"},
		{"opts": ["The accommodation was clean.", "She has great privileges.", "Separate the items carefully.", "His absence was unnoticable."], "ans": 3, "c": "Spelling"},

		{"opts": ["My birthday is in September.", "Mr. Tan is our form teacher.", "We crossed the penang bridge.", "The Merdeka parade was grand."], "ans": 2, "c": "Capitalization"},
		{"opts": ["Can you help me with this?", "What a wonderful goal!", "Why did you leave early.", "Please close the window."], "ans": 2, "c": "Punctuation"},
		{"opts": ["She gave me good advice.", "The principal spoke to us.", "I will loose my keys if not careful.", "The weather had an effect on us."], "ans": 2, "c": "Word Choice"},
		{"opts": ["He complemented her on her singing.", "The hot tea complemented the biscuits.", "We stationary in the parking lot.", "She bought new stationery."], "ans": 2, "c": "Word Choice"},
		{"opts": ["There are fewer students today.", "He drinks less coffee now.", "She has much homework.", "There are less cars on the road."], "ans": 3, "c": "Quantifiers"},

		{"opts": ["The committee has reached a verdict.", "All of the cake is gone.", "Some of the students is absent.", "None of the money was stolen."], "ans": 2, "c": "Subject-Verb Agreement"},
		{"opts": ["If I were you, I would study.", "I wish I had more time.", "He acts as if he knows everything.", "I wish I was a bird."], "ans": 3, "c": "Subjunctive"},
		{"opts": ["She has sung two songs.", "He has drank all the milk.", "They have driven for hours.", "We have chosen our team."], "ans": 1, "c": "Verb Tense"},
		{"opts": ["A herd of cattle is grazing.", "The swarm of bees was loud.", "A pair of shoes are in the box.", "A flock of birds flew south."], "ans": 2, "c": "Subject-Verb Agreement"},
		{"opts": ["He arrived in London yesterday.", "She arrived at the bus stop.", "They arrived in school at 8 AM.", "We arrived home safely."], "ans": 2, "c": "Preposition"},

		{"opts": ["Neither Alyssa nor Mirul is ready.", "Either he or they are coming.", "Neither the teacher nor the students was happy.", "Either you or I am chosen."], "ans": 2, "c": "Subject-Verb Agreement"},
		{"opts": ["She has fewer questions than him.", "We have less water in the bottle.", "There is less traffic on Sunday.", "He has less pens than before."], "ans": 3, "c": "Quantifiers"},
		{"opts": ["The scissors are sharp.", "My trousers are clean.", "The eyeglasses is broken.", "These binoculars are powerful."], "ans": 2, "c": "Singular / Plural"},
		{"opts": ["She graduated from university.", "He succeeded in his exam.", "They insisted on coming along.", "We prevented him to fall."], "ans": 3, "c": "Preposition"},
		{"opts": ["The sun shines brightly.", "The stars glitter in the dark.", "The moon appear above the clouds.", "The wind blows gently."], "ans": 2, "c": "Subject-Verb Agreement"}
	]

	for item in spotter_raw:
		questions.append({
			"type": "sentence_spotter",
			"category": item["c"],
			"prompt": "Which of the four sentences contains a grammatical error?",
			"options": item["opts"],
			"correct_index": item["ans"]
		})

	print("Total questions compiled: %d" % questions.size())
	
	# Generate GDScript file
	var output = "class_name ErrorHuntData extends RefCounted\n\n"
	output += "# Comprehensive question bank with 200+ questions across 4 game modes\n"
	output += "const QUESTIONS: Array[Dictionary] = [\n"
	
	for i in range(questions.size()):
		var q = questions[i]
		output += "\t" + JSON.stringify(q)
		if i < questions.size() - 1:
			output += ",\n"
		else:
			output += "\n"
	output += "]\n"
	
	var file = FileAccess.open("res://minigames/ErrorHuntData.gd", FileAccess.WRITE)
	if file:
		file.store_string(output)
		file.close()
		print("Successfully wrote res://minigames/ErrorHuntData.gd!")
	else:
		print("Failed to write file!")
		quit(1)
		return
		
	quit(0)
