extends Node2D

@onready var score_panel: Panel = $HUD/ScorePanel
@onready var score_label: Label = $HUD/ScorePanel/ScoreLabel
@onready var fade: ColorRect = $HUD/ColorRect

# Accessing the UI elements safely
@onready var level_display: TextureRect = get_node_or_null("%LevelDisplay")
@onready var lives_label: Label = $HUD/ScorePanel/LivesLabel
@onready var progress_label: Label = $HUD/ScorePanel/ProgressLabel

# New Notification Label for animated messages
@onready var notification_label: Label = $HUD/NotificationLabel

# Time Attack Nodes
@onready var time_label: Label = $HUD/ScorePanel/TimeLabel
@onready var level_timer: Timer = $LevelTimer

# Main Menu Nodes
@onready var main_menu: Control = $HUD/MainMenu
@onready var play_button: Button = $HUD/MainMenu/PlayButton
@onready var quit_button: Button = $HUD/MainMenu/QuitButton
@onready var high_score_label: Label = $HUD/MainMenu/HighScoreLabel

# Audio Nodes
@onready var background_music: AudioStreamPlayer = $"back ground"
@onready var death_sound: AudioStreamPlayer = $DeathSound

var level: int = 1
var score: int = 0
var current_level_root: Node = null

# Global player lives tracker (Starts with 3 lives)
var lives: int = 3

# Track level progression (Apples collected in current level)
var total_apples_in_level: int = 0
var collected_apples_in_level: int = 0

# Idle player detection variables
var idle_time: float = 0.0
const IDLE_THRESHOLD: float = 5.0
var is_showing_idle_msg: bool = false

# Screen Shake variables
var shake_intensity: float = 0.0
var camera_node: Camera2D = null

# High Score Save Path
const SAVE_FILE_PATH = "user://highscore.save"
var high_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fade.modulate.a = 0.0 # Start clear so menu is visible
	current_level_root = get_node_or_null("LevelRoot")
	
	# Connect Timer timeout signal programmatically
	if level_timer:
		level_timer.timeout.connect(_on_timer_timeout)
		
	# Connect Main Menu Buttons programmatically
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_button_pressed)
	
	# Load high score from device memory
	_load_high_score()
	_update_high_score_ui()
	
	# Make sure gameplay elements are hidden on boot
	if score_panel:
		score_panel.visible = false
		
	if current_level_root:
		current_level_root.queue_free() # Don't run the level until Play is pressed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# 1. Handle Screen Shake processing
	if shake_intensity > 0.0 and camera_node:
		camera_node.offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		shake_intensity = lerp(shake_intensity, 0.0, delta * 5.0)
		if shake_intensity < 0.1:
			shake_intensity = 0.0
			camera_node.offset = Vector2.ZERO

	# 2. Update Time Attack UI Label
	if level_timer and level_timer.time_left > 0:
		time_label.text = "TIME: %d" % ceil(level_timer.time_left)

	# 3. Handle Player Idle detection
	var player = get_node_or_null("LevelRoot/player")
	if player:
		if not camera_node:
			camera_node = player.get_node_or_null("Camera2D")
			
		if player.get("velocity") and player.velocity.length() < 1.0:
			if not is_showing_idle_msg:
				idle_time += delta
				if idle_time >= IDLE_THRESHOLD:
					is_showing_idle_msg = true
					idle_time = 0.0
					_show_idle_warning()
		else:
			idle_time = 0.0

#-------------------
# Main Menu Actions

func _on_play_button_pressed() -> void:
	if main_menu:
		main_menu.visible = false
	if score_panel:
		score_panel.visible = true
		
	# Initialize the hearts UI
	_update_lives_ui()
	
	# Play background music ONLY after pressing PLAY
	if background_music and not background_music.playing:
		background_music.play()
		
	fade.modulate.a = 1.0
	await _load_level(level, true, false)
	
	# Show the animated notification label ONLY after game starts
	await _show_juice_message("LET'S GO! CHOP CHOP! ⚡", 2.0)

func _on_quit_button_pressed() -> void:
	get_tree().quit()

# Helper function to show idle warning asynchronously
func _show_idle_warning() -> void:
	await _show_juice_message("HEY! MOVE ON! 🏃‍♂️🔥", 1.5)
	is_showing_idle_msg = false

# Trigger Screen Shake
func trigger_shake(intensity: float) -> void:
	shake_intensity = intensity

# Level management 
func _load_level(level_number: int, first_load: bool, reset_score: bool) -> void:
	if not first_load:
		await _fade(1.0)
		
	if reset_score:
		_check_and_save_highscore()
		score = 0
		score_label.text = "SCORE: 0"
		
	if current_level_root:
		current_level_root.queue_free()
		current_level_root = null
		
	# Update the level image display dynamically from the levels folder
	if level_display:
		var image_path = "res://levels/0%s.png" % level_number
		if ResourceLoader.exists(image_path):
			level_display.texture = load(image_path)
		
	var level_path = "res://levels/level%s.tscn" % level_number
	
	if ResourceLoader.exists(level_path):
		var level_resource = load(level_path)
		current_level_root = level_resource.instantiate()
		add_child(current_level_root)
		current_level_root.name = "LevelRoot"
		_setup_level(current_level_root)
	else:
		print("Level file not found. Game over.")
		return 

	if background_music and not background_music.playing:
		background_music.play()

	await _fade(0.0)
	
func _setup_level(level_root: Node) -> void:
	collected_apples_in_level = 0
	total_apples_in_level = 0
	idle_time = 0.0
	camera_node = null
	
	# Start Level Timer (Set to 30 seconds for Level 1, 45 seconds for Level 2)
	if level_timer:
		var time_allocated = 30.0 if level == 1 else 45.0
		level_timer.start(time_allocated)
	
	# Connect Exit
	var exit_node = level_root.get_node_or_null("exit")
	if not exit_node:
		exit_node = level_root.get_node_or_null("exite")
		
	if exit_node:
		exit_node.body_entered.connect(_on_exit_body_entered)
		
	# Connect Apples and calculate total apples for progress tracking
	var apples = level_root.get_node_or_null("Apples")
	if apples:
		total_apples_in_level = apples.get_child_count()
		for apple in apples.get_children():
			if apple.has_signal("collected"):
				apple.collected.connect(increase_score)
				
	_update_progress_ui()
			
	# Connect Enemies
	var enemies = level_root.get_node_or_null("Enemies")
	if enemies:
		for enemy in enemies.get_children():
			if enemy.has_signal("player_died"):
				enemy.player_died.connect(_on_player_died)

#-------------------
# Signal Handlers

func _on_timer_timeout() -> void:
	trigger_shake(15.0)
	_show_juice_message("TIME OUT! ⏱️❌", 1.5)
	
	var player = get_node_or_null("LevelRoot/player")
	if player:
		_on_player_died(player)

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "player":
		if level_timer:
			level_timer.stop()
			
		var next_level = level + 1
		var next_path = "res://levels/level%s.tscn" % next_level
		
		if ResourceLoader.exists(next_path):
			level = next_level
			body.can_move = false
			
			await _show_juice_message("LEVEL CLEARED! 🎉", 1.5)
			await _load_level(level, false, false)
			_show_juice_message("LEVEL %s.. FIGHT! ⚔️" % level, 1.5)
		else:
			body.can_move = false
			_check_and_save_highscore()
			await _show_juice_message("VICTORY! YOU ARE THE BEST! 🏆", 3.0)
			await _fade(1.0)
			get_tree().quit()

func _on_player_died(body):
	if level_timer:
		level_timer.stop()

	if background_music:
		background_music.stop()
		
	if death_sound:
		death_sound.play()

	trigger_shake(8.0)

	if body.has_method("die"):
		body.die()
	
	lives -= 1
	_update_lives_ui()
	idle_time = 0.0
	
	if lives <= 0:
		_check_and_save_highscore()
		await _show_juice_message("GAME OVER 💀", 2.0)
		await get_tree().create_timer(1.0).timeout
		await _fade(1.0)
		get_tree().quit()
		return
	elif lives == 1:
		_show_juice_message("WARNING: LAST HEART! ⚠️\nDON'T DIE!", 2.0)
	else:
		_show_juice_message("OUCH! HEART LOST!💔", 1.2)
	
	await get_tree().create_timer(1.0).timeout
	
	if level == 1:
		await _load_level(level, false, true)
	elif level == 2:
		level = 1
		await _load_level(level, false, true)
		_show_juice_message("BACK TO LEVEL 1! TRY HARDER! 🔥", 1.8)

func increase_score() -> void:
	score += 1
	score_label.text = "SCORE: %s" % score
	idle_time = 0.0
	trigger_shake(2.0)
	
	collected_apples_in_level += 1
	_update_progress_ui()
	
	if collected_apples_in_level == total_apples_in_level:
		_show_juice_message("ALL APPLES COLLECTED! GO TO EXIT! 🌟", 2.0)
	else:
		_show_juice_message("NICE! +1 APPLE ⭐", 0.6)

#-------------------
# Save System & High Score Logic

func _check_and_save_highscore() -> void:
	if score > high_score:
		high_score = score
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
		if file:
			file.store_32(high_score)
			file.close()
		_update_high_score_ui()

func _load_high_score() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			high_score = file.get_32()
			file.close()
	else:
		high_score = 0

func _update_high_score_ui() -> void:
	if high_score_label:
		high_score_label.text = "HIGH SCORE: %d" % high_score

#-------------------
# Helper UI Systems

func _update_progress_ui() -> void:
	if progress_label:
		if total_apples_in_level > 0:
			var filled_bars: int = collected_apples_in_level
			var empty_bars: int = total_apples_in_level - collected_apples_in_level
			
			var bar_text = ""
			for i in range(filled_bars):
				bar_text += "⭐"
			for i in range(empty_bars):
				bar_text += "⚫"
				
			progress_label.text = "PROGRESS: " + bar_text
		else:
			progress_label.text = "PROGRESS: "

func _update_lives_ui() -> void:
	if lives_label:
		var hearts_text = ""
		for i in range(max(0, lives)):
			hearts_text += "❤️ "
		lives_label.text = hearts_text
 
func _fade(to_alpha: float) -> void:
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished 

func _show_juice_message(message_text: String, duration: float) -> void:
	if not notification_label:
		return
		
	notification_label.text = message_text
	notification_label.reset_size()
	notification_label.pivot_offset = notification_label.size / 2
	
	var juice_tween = create_tween().set_parallel(true)
	notification_label.modulate.a = 0.0
	notification_label.scale = Vector2(0.5, 0.5)
	
	juice_tween.tween_property(notification_label, "modulate:a", 1.0, 0.2)
	juice_tween.tween_property(notification_label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(duration).timeout
	
	var fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(notification_label, "modulate:a", 0.0, 0.3)
	fade_tween.tween_property(notification_label, "scale", Vector2(0.7, 0.7), 0.3)
	
	await fade_tween.finished
