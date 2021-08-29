extends Node2D

var sound_library = {
	"powerup": ["res://assets/sound/powerup.wav", -5],
	"shoot": ["res://assets/sound/shoot.wav", -5],
	"explosion": ["res://assets/sound/explosion.wav", -5],
	"hit": ["res://assets/sound/hit.wav", -5],
	"blip": ["res://assets/sound/blip.wav", -5],
	"blip_reverse": ["res://assets/sound/blip_reverse.wav", -5],
	"freeze": ["res://assets/sound/freeze.wav", -5]
}

var music_path = preload("res://assets/sound/Constipation Man - Space Race.mp3")

var music_volume = -25

var stream_library = {}

func _ready():
	for key in sound_library:
		var sound_node = AudioStreamPlayer.new()
		var stream  = load(sound_library[key][0])
		sound_node.set_stream(stream)
		sound_node.volume_db = sound_library[key][1]
		sound_node.set_bus("FX")
		add_child(sound_node)
		stream_library[key] = sound_node
	$Music.volume_db = music_volume
	$Music.set_stream(music_path)
	$Music.play()

func play_sound(sound_str):
	if sound_str in stream_library:
		stream_library[sound_str].play()
