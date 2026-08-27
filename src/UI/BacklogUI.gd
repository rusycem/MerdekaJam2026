extends CanvasLayer
class_name BacklogUI

var scroll: ScrollContainer
var vbox: VBoxContainer
var vn_player: Node
var dim: ColorRect

func _init(player: Node):
	vn_player = player
	layer = 50
	
	dim = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	
	var title = Label.new()
	title.text = "LOG"
	title.add_theme_font_size_override("font_size", 24)
	title.set_anchors_preset(Control.PRESET_TOP_LEFT)
	title.position = Vector2(20, 20)
	add_child(title)
	
	scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 100
	scroll.offset_right = -100
	scroll.offset_top = 80
	scroll.offset_bottom = -20
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	
	vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 20)
	scroll.add_child(vbox)
	
	hide()

func open():
	# Clear old backlog
	for c in vbox.get_children():
		c.queue_free()
		
	# Build new backlog
	for entry in vn_player.dialogue_history:
		var row = VBoxContainer.new()
		var top_row = HBoxContainer.new()
		
		var speaker = Label.new()
		var spk_name = entry["speaker"].strip_edges()
		
		if spk_name == "": spk_name = "System"
			
		speaker.text = spk_name
		speaker.add_theme_font_size_override("font_size", 20)
		
		if spk_name == "System":
			speaker.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		elif spk_name == "Narrator":
			speaker.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			speaker.add_theme_color_override("font_color", Color(1, 0.8, 0.4))
			
		top_row.add_child(speaker)
		
		if entry["voice_uid"] != "":
			var play_btn = Button.new()
			play_btn.text = " Play Voice "
			play_btn.pressed.connect(func():
				var stream = ResourceLoader.load(entry["voice_uid"])
				if stream:
					vn_player.voice_player.stream = stream
					vn_player.voice_player.play()
			)
			top_row.add_child(play_btn)
			
		row.add_child(top_row)
		
		var text = RichTextLabel.new()
		text.bbcode_enabled = true
		text.text = entry["text"]
		text.fit_content = true
		text.add_theme_font_size_override("normal_font_size", 18)
		row.add_child(text)
		
		var sep = HSeparator.new()
		row.add_child(sep)
		vbox.add_child(row)
		
	show()
	await get_tree().process_frame
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

func close():
	hide()
