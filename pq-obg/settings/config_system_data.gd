extends Resource
class_name ConfigSystemData

@export_group("Game")
@export var game_id : String = "game-id"
@export var game_version : String = "1.0.0"
@export var game_author : String = "Tiamo Pastoor"
@export var language_default := "en"
@export var game_scene : String
@export var fullscreen := true

@export_group("Settings")
# resources for SettingTabs to display
@export var settings : Array[SettingTab] = [preload("res://pq-obg/settings/default/tab_core.tres"), preload("res://pq-obg/settings/default/theme/tab_theme.tres")] 
@export var settings_only_load_through_menu := false

@export_group("Audio")
@export var volume_game := 1.0
@export var volume_background := 0.6
@export var volume_ui := 0.6
@export var audio_bg : Array[AudioStream] = []
@export var audio_ui : AudioStream = preload("res://pq-obg/audio/sfx/ui_click.mp3")
@export var audio_player_change : AudioStream = preload("res://pq-obg/audio/sfx/ui_click.mp3")

@export_group("Theme")
@export var theme : Theme = preload("res://pq-obg/ui/default_theme.tres")

@export_subgroup("Background")
@export var bg_color := Color.WHITE
@export var bg_image : Texture2D
@export var bg_scene := ""

@export_subgroup("Fonts")
@export var use_system_fonts := false
@export var font_size : int = 32
@export var font_body_regular : FontFile
@export var font_body_italic : FontFile
@export var font_body_bold : FontFile
@export var font_body_bold_italic : FontFile
@export var font_heading : FontFile
@export var font_special : FontFile

@export_subgroup("Colors")
@export var color_scheme_auto_generate := true
@export var color_main := Color(0.0, 0.731, 0.636, 1.0)
@export var color_normal_bg := Color(0.941, 0.867, 0.788)
@export var color_normal_text := Color(0.239, 0.18, 0.0)
@export var color_focus_bg := Color(0.651, 0.176, 0.329)
@export var color_focus_text := Color(1.0, 0.671, 0.757)
@export var color_hover_bg := Color(0.376, 0.212, 0.082)
@export var color_hover_text := Color(1.0, 0.878, 0.8)
@export var color_panel_bg := Color(0.941, 0.867, 0.788)
@export var color_shadow := Color(0.0, 0.0, 0.0, 0.4)

@export_subgroup("Shadows")
@export var shadow_offset := Vector2(0,6)
@export var shadow_size_normal := 0.0
@export var shadow_size_focus := 0.0
@export var shadow_size_hover := 0.0
@export var shadow_size_panel := 0.0

@export_subgroup("Borders")
@export var border_radius := 12
@export var border_margin := 12
@export var border_margin_panel := 16
@export var border_width := 4
@export var border_color_normal := Color.TRANSPARENT
@export var border_color_focus := Color.TRANSPARENT
@export var border_color_hover := Color.TRANSPARENT
@export var border_color_panel := Color(0.941, 0.545, 0.475)

@export_subgroup("Labels")
@export var label_color := Color.BLACK
@export var label_font_size : int = 32

@export_subgroup("Buttons")
@export var button_font_size : int = 42

@export_subgroup("Margins")
@export var container_margin_default := 32
@export var container_separation_default := 20

@export_group("Input")
@export_subgroup("Players")
@export var input_min_players_bound := 2
@export var input_max_players_bound := 8
@export var input_max_players := 8

@export_subgroup("Input Types")
@export var input_allow_keyboard := true
@export var input_allow_mouse := true
@export var input_allow_gamepad := true
@export var input_allow_touch := true
@export var input_max_gamepads := 4
@export var input_max_touch := 4
@export var input_allow_left_mouse_button := false
@export var input_allow_gamepad_accept_button := false

@export_subgroup("Touch")
@export var touch_area_size := Vector2(192.0, 192.0)
@export var touch_area_alpha := 0.4

@export_subgroup("Login & Logout")
@export var input_login_while_playing := true
@export var input_logout_while_playing := true
@export var input_logout_hold_duration := 2.0 # ~seconds
@export var allow_login_by_clicking_instruction := true
@export var input_removal_type := InputManager.ButtonRemovalType.HOLD_COND
@export var input_check_login_on_released := true
@export var clear_input_at_menu := true

@export_group("Players")
@export var player_colors : Array[Color] = [
	Color("#d2849c"),
	Color("#96a85e"),
	Color("#60a7d6"),
	
	Color("#cc8f5c"),
	Color("#4bb3a1"),
	Color("#a890d4"),
	
	Color("#d58679"),
	Color("#6fb07d"),
	Color("#869bdd"),
	
	Color("#b79c51"),
	Color("#43afc1"),
	Color("#c287bc"),
]

# how people are scored/ranked/win per match/round
@export_group("Match Objective")
@export var match_victory_type := Objective.VictoryType.TIME
@export var match_victory_extreme := Objective.VictoryExtreme.LOWEST
@export var match_victory_metric := Objective.VictoryMetric.RANKING

# how people are tracked in overall standings (across multiple matches)
@export_group("Game Objective")
@export var game_victory_type := Objective.VictoryType.POINTS
@export var game_victory_extreme := Objective.VictoryExtreme.LOWEST
@export var game_victory_metric := Objective.VictoryMetric.RANKING
@export var game_victory_conversion := Objective.VictoryConversion.RANKING

@export_group("Tutorial")
@export var tutorial_enabled := true
@export var tutorials : Array[TutorialStage] = []
@export var tutorials_debug : Array[TutorialStage] = []
@export var tutorial_delay := 6.0 # seconds before next tutorial appears
@export var tutorial_delay_remove := 12.0 # seconds before that tutorial fades away again
@export var tutorial_scale := 1.0
@export var tutorial_heading_font_size : int = 16
@export var tutorial_content_font_size : int = 16
@export var tutorial_only_once := true # if so, doesn't repeat the tutorial any time you pause

@export_group("UI")
@export var tutorial_anchor := ScreenAnchorTool.Anchor.CENTER
@export var settings_panel_size := Vector2(1100.0, 700.0)
@export var ui_overlay_alpha := 0.25

@export_subgroup("Pause & GameOver Menu")
@export var pause_menu_width := 512.0
@export var pause_menu_anchor := ScreenAnchorTool.Anchor.BOTTOM

@export_subgroup("Button Instructions")
@export var button_instructions_anchor := ScreenAnchorTool.Anchor.TOP
@export var button_instructions_icon_size : int = 42
@export var button_instructions_font_size : int = 19
@export var button_instructions_panel := false
@export var button_instruction_width := 192.0

@export_subgroup("Button Visualizer")
@export var button_visualizer_scene := preload("res://pq-obg/ui/button_visualizer/button_visualizer.tscn")
@export var button_visualizer_scale_base := 0.1
@export var button_visualizer_scale := 1.0

@export_subgroup("Icons")
@export var icon_play : Texture = preload("res://pq-obg/ui/textures/icon_play.tres")
@export var icon_quit : Texture = preload("res://pq-obg/ui/textures/icon_quit.tres")
@export var icon_reset : Texture = preload("res://pq-obg/ui/textures/icon_reset.tres")
@export var icon_settings : Texture = preload("res://pq-obg/ui/textures/icon_settings.tres")
