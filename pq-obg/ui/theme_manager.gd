extends Node
class_name ThemeManager

enum FontType
{
	BODY_REGULAR,
	BODY_ITALIC,
	BODY_BOLD,
	BODY_BOLD_ITALIC,
	HEADING,
	SPECIAL
}

const FONT_TYPE_CONFIG_KEYS : Dictionary[FontType, String] = {
	FontType.BODY_REGULAR: "font_body_regular",
	FontType.BODY_ITALIC: "font_body_italic",
	FontType.BODY_BOLD: "font_body_bold",
	FontType.BODY_BOLD_ITALIC: "font_body_bold_italic",
	FontType.HEADING: "font_heading",
	FontType.SPECIAL: "font_special",
}

var system_font : SystemFont

func _ready() -> void:
	ProjectSettings.set_setting("gui/theme/custom", Global.config_system.theme)
	
	cache_system_font()
	refresh()

func cache_system_font() -> void:
	system_font = SystemFont.new()
	system_font.font_names = ["Helvetica", "Arial", "Georgia"]

func get_font(type:FontType) -> Font:
	if Global.config_system.use_system_fonts: return system_font
	var key := FONT_TYPE_CONFIG_KEYS[type]
	var font : Font = Global.config_system[key]
	if not font: return system_font
	return font

static func lerp_hue(a:float, b:float, factor:float) -> float:
	var dist := absf(a - b)
	# if we're more than 180 degrees away, 
	# change b to be on the "short side" instead
	if dist > 0.5:
		b = a + (1.0 - dist)
	
	# now we can simply lerp between them
	var lerped := lerpf(a,b,factor)
	
	# and clamp to [0,1] because that's what Godot wants
	var lerped_clamped := lerped - floorf(lerped)
	
	return lerped_clamped

## It looks better when darkening colors to also move their hue towards dark blue/purple
static func darken_smart(c:Color, diff:float) -> Color:
	var col := c.darkened(diff)
	var anti_yellow_hue := (240/360.0)
	col.h = lerp_hue(col.h, anti_yellow_hue, 0.05)
	return col

## It looks better when lightening colors to also move their hue more towards yellow
static func lighten_smart(c:Color, diff:float) -> Color:
	var col := c.lightened(diff)
	var yellow_hue := (60/360.0)
	col.h = lerp_hue(col.h, yellow_hue, 0.05)
	return col

static func get_most_contrasting_grayscale(c:Color) -> Color:
	return Color.BLACK if c.get_luminance() > 0.5 else Color.WHITE
	
static func get_most_contrasting_shade(c:Color, diff := 0.2) -> Color:
	return darken_smart(c,diff) if c.get_luminance() > 0.5 else lighten_smart(c, diff)

static func get_least_contrasting_shade(c:Color, diff := 0.2) -> Color:
	return darken_smart(c,diff) if c.get_luminance() < 0.5 else lighten_smart(c, diff)

func generate_color_scheme(base:Color) -> void:
	var cfg = Global.config_system
	
	var normal_bg := get_least_contrasting_shade(base, 0.8)
	var normal_text := get_most_contrasting_grayscale(normal_bg)
	cfg.label_color = normal_text
	
	cfg.color_normal_bg = normal_bg
	cfg.color_normal_text = normal_text
	cfg.color_focus_bg = base
	cfg.color_focus_text = get_most_contrasting_grayscale(base)
	cfg.color_hover_bg = get_most_contrasting_shade(base, 0.5)
	cfg.color_hover_text = base
	cfg.color_panel_bg = normal_bg
	cfg.border_color_normal = Color.TRANSPARENT
	cfg.border_color_focus = get_most_contrasting_grayscale(base)
	cfg.border_color_hover = get_most_contrasting_shade(base, 0.2)
	cfg.border_color_panel = get_most_contrasting_shade(base, 0.2)

func refresh():
	var cfg = Global.config_system
	var th : Theme = Theme.new()
	
	#
	# Colorscheme
	# This just overrides the config values we'll read below with what the color scheme dictates
	#
	if cfg.color_scheme_auto_generate:
		generate_color_scheme(cfg.color_main)
	
	#
	# Main Properties
	#
	if not cfg.use_system_fonts:
		th.default_font = cfg.font_body_regular
	th.default_font_size = cfg.font_size
	
	#
	# Prepare Style Boxes for Reuse
	#
	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = cfg.color_normal_bg
	sb_normal.border_color = cfg.border_color_normal
	sb_normal.set_border_width_all(cfg.border_width)
	sb_normal.set_corner_radius_all(cfg.border_radius)
	sb_normal.set_content_margin_all(cfg.border_margin)
	sb_normal.shadow_size = cfg.shadow_size_normal
	sb_normal.shadow_color = cfg.color_shadow
	sb_normal.shadow_offset = cfg.shadow_offset
	
	var sb_focus := StyleBoxFlat.new()
	sb_focus.bg_color = cfg.color_focus_bg
	sb_focus.border_color = cfg.border_color_focus
	sb_focus.set_border_width_all(cfg.border_width)
	sb_focus.set_corner_radius_all(cfg.border_radius)
	sb_focus.set_content_margin_all(cfg.border_margin)
	sb_focus.shadow_size = cfg.shadow_size_focus
	sb_focus.shadow_color = cfg.color_shadow
	sb_focus.shadow_offset = cfg.shadow_offset
	
	var sb_focus_small := sb_focus.duplicate_deep()
	sb_focus_small.set_corner_radius_all(roundi(0.25*cfg.border_radius))
	
	var sb_hover := StyleBoxFlat.new()
	sb_hover.bg_color = cfg.color_hover_bg
	sb_hover.border_color = cfg.border_color_hover
	sb_hover.set_border_width_all(cfg.border_width)
	sb_hover.set_corner_radius_all(cfg.border_radius)
	sb_hover.set_content_margin_all(cfg.border_margin)
	sb_hover.shadow_size = cfg.shadow_size_hover
	sb_hover.shadow_color = cfg.color_shadow
	sb_hover.shadow_offset = cfg.shadow_offset
	
	var sb_hover_small := sb_hover.duplicate_deep()
	sb_hover_small.set_corner_radius_all(roundi(0.25*cfg.border_radius))
	
	var sb_panel := StyleBoxFlat.new()
	sb_panel.bg_color = cfg.color_panel_bg
	sb_panel.border_color = cfg.border_color_panel
	sb_panel.set_border_width_all(cfg.border_width)
	sb_panel.set_corner_radius_all(cfg.border_radius)
	sb_panel.set_content_margin_all(cfg.border_margin_panel)
	sb_panel.shadow_size = cfg.shadow_size_panel
	sb_panel.shadow_color = cfg.color_shadow
	sb_panel.shadow_offset = cfg.shadow_offset
	
	#
	# Button
	# @NOTE: The Button styles are directly inherited by a lot of other things (e.g. CheckButton, OptionButton)
	# So making sure these are correct and set here is important
	#
	th.set_font("font", "Button", cfg.font_heading)
	if cfg.use_system_fonts: th.set_font("font", "Button", system_font)
	th.set_font_size("font_size", "Button",cfg.button_font_size)
	th.set_stylebox("focus", "Button", sb_focus)
	th.set_stylebox("hover", "Button", sb_hover)
	th.set_stylebox("pressed", "Button", sb_hover)
	th.set_stylebox("normal", "Button", sb_normal)
	
	th.set_color("font_color", "Button", cfg.color_normal_text)
	th.set_color("font_focus_color", "Button", cfg.color_focus_text)
	th.set_color("font_hover_color", "Button", cfg.color_hover_text)
	th.set_color("font_pressed_color", "Button", cfg.color_hover_text)
	th.set_color("font_hover_pressed_color", "Button", cfg.color_normal_text)
	
	#
	# OptionButton
	#
	th.set_font("font", "OptionButton", cfg.font_body_regular)
	if cfg.use_system_fonts: th.set_font("font", "OptionButton", system_font)
	th.set_stylebox("hover", "OptionButton", sb_hover_small)
	th.set_stylebox("focus", "OptionButton", sb_focus_small)
	th.set_stylebox("pressed", "OptionButton", sb_focus_small)
	
	#
	# CheckButton
	#
	th.set_font("font", "CheckButton", cfg.font_body_regular)
	th.set_font_size("font_size", "CheckButton", cfg.label_font_size)
	if cfg.use_system_fonts: th.set_font("font", "CheckButton", system_font)
	
	th.set_stylebox("focus", "CheckButton", StyleBoxEmpty.new())
	th.set_stylebox("pressed", "CheckButton", StyleBoxEmpty.new())
	th.set_stylebox("normal", "CheckButton", StyleBoxEmpty.new())
	th.set_stylebox("hover", "CheckButton", StyleBoxEmpty.new())
	
	th.set_color("font_color", "CheckButton", cfg.color_normal_text)
	th.set_color("font_focus_color", "CheckButton", cfg.color_normal_text)
	th.set_color("font_hover_color", "CheckButton", cfg.color_normal_text)
	th.set_color("font_pressed_color", "CheckButton", cfg.color_normal_text)
	th.set_color("font_hover_pressed_color", "CheckButton", cfg.color_normal_text)
	
	#
	# Label
	#
	th.set_font("font", "Label", cfg.font_body_regular)
	if cfg.use_system_fonts: th.set_font("font", "Label", system_font)
	th.set_color("font_color", "Label", cfg.label_color)
	th.set_font_size("font_size", "Label", cfg.label_font_size)
	
	#
	# RichTextLabel
	#
	th.set_font("normal_font", "RichTextLabel", cfg.font_body_regular)
	th.set_font("bold_font", "RichTextLabel", cfg.font_body_bold)
	th.set_font("bold_italics_font", "RichTextLabel", cfg.font_body_bold_italic)
	th.set_font("italics_font", "RichTextLabel", cfg.font_body_italic)
	
	if cfg.use_system_fonts: 
		th.set_font("normal_font", "RichTextLabel", system_font)
		th.set_font("bold_font", "RichTextLabel", system_font)
		th.set_font("bold_italics_font", "RichTextLabel", system_font)
		th.set_font("italics_font", "RichTextLabel", system_font)
	
	th.set_font_size("normal_font_size", "RichTextLabel", cfg.label_font_size)
	th.set_font_size("bold_font_size", "RichTextLabel", cfg.label_font_size)
	th.set_font_size("bold_italics_font_size", "RichTextLabel", cfg.label_font_size)
	th.set_font_size("italics_font_size", "RichTextLabel",cfg.label_font_size)
	
	#
	# TabContainer
	#
	th.set_font("font", "TabContainer", cfg.font_heading)
	if cfg.use_system_fonts: th.set_font("font", "TabContainer", system_font)
	th.set_color("font_selected_color", "TabContainer", cfg.color_focus_text)
	th.set_color("font_hovered_color", "TabContainer", cfg.color_hover_text)
	th.set_color("font_unselected_color", "TabContainer", cfg.label_color)
	th.set_color("font_disabled_color", "TabContainer", Color(0,0,0,0.5))
	
	th.set_stylebox("panel", "TabContainer", StyleBoxEmpty.new())
	th.set_stylebox("tab_focus", "TabContainer", sb_focus)
	th.set_stylebox("tab_hovered", "TabContainer", sb_hover)
	th.set_stylebox("tab_selected", "TabContainer", sb_focus)
	th.set_stylebox("tab_unselected", "TabContainer", sb_normal)
	
	#
	# PanelContainer
	#
	th.set_stylebox("panel", "PanelContainer", sb_panel)
	
	#
	# HSlider
	#
	th.set_stylebox("grabber_area", "HSlider", sb_normal)
	th.set_stylebox("grabber_area_highlight", "HSlider", sb_focus)
	th.set_stylebox("slider", "HSlider", sb_hover)
	
	#
	# MarginContainer
	#
	th.set_constant("margin_bottom", "MarginContainer", cfg.container_margin_default)
	th.set_constant("margin_top", "MarginContainer", cfg.container_margin_default)
	th.set_constant("margin_left", "MarginContainer", cfg.container_margin_default)
	th.set_constant("margin_right", "MarginContainer", cfg.container_margin_default)
	
	#
	# HBox / VBox
	#
	th.set_constant("separation", "HBoxContainer", cfg.container_separation_default)
	th.set_constant("separation", "VBoxContainer", cfg.container_separation_default)
	
	#
	# Tooltips
	#
	th.set_color("font_color", "TooltipLabel", Color.WHITE)
	
	#
	# Scrollbars
	#
	th.set_stylebox("scroll", "VScrollBar", sb_normal)
	th.set_stylebox("scroll_focus", "VScrollBar", sb_hover)
	th.set_stylebox("grabber_highlight", "VScrollBar", sb_focus)
	th.set_stylebox("grabber_pressed", "VScrollBar", sb_focus)
	
	# we only swap the shared theme with the new one at the end
	# so it only updates ONCE, after all properties have been set again
	var shared_theme : Theme = cfg.theme
	shared_theme.clear()
	shared_theme.merge_with(th)
