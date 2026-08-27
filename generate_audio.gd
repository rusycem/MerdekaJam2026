extends SceneTree

func _init():
	print("Generating Audio Files...")
	
	# Generate Blip (Short sine wave)
	var blip = AudioStreamWAV.new()
	blip.format = AudioStreamWAV.FORMAT_16_BITS
	blip.mix_rate = 44100
	blip.stereo = false
	var blip_data = PackedByteArray()
	for i in range(44100 * 0.05): # 50ms blip
		var t = i / 44100.0
		var sample = int(sin(t * 2.0 * PI * 800.0) * 16000.0 * exp(-t * 30.0))
		blip_data.append(sample & 0xFF)
		blip_data.append((sample >> 8) & 0xFF)
	blip.data = blip_data
	ResourceSaver.save(blip, "res://assets/audio/blip.tres")
	
	print("Done.")
	quit()
