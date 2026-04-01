extends Resource
class_name Setting 

enum Type
{
	CHECKBOX,
	RANGE,
	RANGE_DISCRETE,
	DROPDOWN,
	COLOR
}

enum TypeDisplay
{
	NONE,
	INT,
	FLOAT, # default
	VOLUME,
	BOOL,
	COLOR
}

enum TypeUnit
{
	NONE,
	DECIBELS,
	SECONDS,
	MILLISECONDS,
	PIXELS
}

@export var type : Type
@export var type_display := TypeDisplay.FLOAT
@export var type_unit := TypeUnit.NONE
@export var key : String
@export var label : String
var section := "Shared"
## @NOTE: very important, don't duplicate settings with a default set, because it will share reference to that one string, which breaks all those resources! Just retype any strings
@export var default : String
@export_multiline var callback : String
@export var min_value := -INF
@export var max_value := INF
@export var step_value := 0
@export var options : Array[Variant] = []
@export_multiline var callback_init : String

@export var needs_theme_refresh := false
@export var needs_input_refresh := false

var reset_button_scene := preload("res://pq-obg/settings/settings_reset_button.tscn")

var value : Variant # last known/changed value
var value_node : Label
var control_node : Control
var label_node : Label
var reset_btn : Button

func fast_construct_helper(tp:Type, l:String, k:String, def:String = "") -> Setting:
	type = tp
	label = l
	key = k
	default = def
	return self

func set_section(s:String) -> Setting:
	section = s
	return self

# @NOTE: This must be a string with GDScript code using `v` (input value) and `r` (setting_reader)
func set_callback(f:String) -> Setting:
	callback = f
	return self

func set_numeric_bounds(minimum:float, maximum:float) -> Setting:
	min_value = minimum
	max_value = maximum
	return self

func set_options(opts:Array[Variant]) -> Setting:
	options = opts
	return self

func set_display_type(tp:TypeDisplay) -> Setting:
	type_display = tp
	return self

func initialize() -> void:
	run_custom_initialization()
	ensure_matching_types()
	
	# if we have no default set yet, save it now BEFORE overwriting anything, so we read from the true original Global.config
	if get_default() == null:
		set_default(Global.state.read_default_value(self))
	
	_on_value_changed(Global.state.read_value(self))

func ensure_matching_types() -> void:
	if type == Type.COLOR: type_display = TypeDisplay.COLOR
	if type == Type.CHECKBOX: type_display = TypeDisplay.BOOL
	if type == Type.RANGE_DISCRETE: type_display = TypeDisplay.INT
	if type == Type.DROPDOWN: type_display = TypeDisplay.NONE

func reset() -> void:
	_on_value_changed(get_default())
	force_update_control()

func get_label_sanitized() -> String:
	return label.strip_edges(true, true)

func get_tooltip_key() -> String:
	var id := get_label_sanitized() + "_TT"
	var is_translatable := tr(id) != id
	if is_translatable: return id
	return ""

func visualize() -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	create_label_node()
	create_value_node()
	
	hbox.add_child(label_node)
	
	if type == Type.COLOR:
		var cpb := ColorPickerButton.new()
		control_node = cpb
		
		var picker := cpb.get_picker()
		picker.can_add_swatches = false
		picker.edit_intensity = false
		picker.color_modes_visible = false
		picker.hex_visible = false
		picker.presets_visible = false
		picker.sliders_visible = false
		
		cpb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cpb.color_changed.connect(_on_value_changed)
	
	if type == Type.DROPDOWN:
		value_node.set_visible(false)
		
		var dd := OptionButton.new()
		control_node = dd
		
		for option in options:
			dd.add_item(option)
		
		dd.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dd.item_selected.connect(func(idx:int):
			_on_value_changed(dd.get_item_text(idx))
		)
	
	if type == Type.CHECKBOX:
		label_node.set_visible(false)
		
		var cb := CheckButton.new()
		control_node = cb
		
		cb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cb.set_text(get_label_sanitized())
		cb.toggled.connect(_on_value_changed)
	
	if type == Type.RANGE or type == Type.RANGE_DISCRETE:
		var slider := HSlider.new()
		control_node = slider
		
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.size_flags_vertical = Control.SIZE_EXPAND_FILL
		if min_value != -INF: slider.min_value = min_value
		if max_value != INF: slider.max_value = max_value
		
		# we want a step size that includes the default value
		var range_diff := (slider.max_value - slider.min_value)
		var diff_to_default := float(get_default()) - slider.min_value
		var desired_step_size := range_diff / 20.0
		var num_steps_to_default := ceilf(diff_to_default / desired_step_size)
		var step := diff_to_default / num_steps_to_default
		
		if type == Type.RANGE_DISCRETE: 
			slider.min_value = floori(slider.min_value)
			slider.max_value = ceili(slider.max_value)
			step = 1
		
		if step_value > 0: step = step_value
		slider.step = step
		
		slider.value_changed.connect(_on_value_changed)
	
	hbox.add_child(control_node)
	hbox.add_child(value_node)
	
	var give_tooltip_to_control := control_node is CheckButton
	var tooltip_node := control_node if give_tooltip_to_control else hbox
	var tooltip = get_tooltip_key()
	tooltip_node.tooltip_text = tooltip
	
	reset_btn = reset_button_scene.instantiate()
	reset_btn.pressed.connect(reset)
	hbox.add_child(reset_btn)
	
	# init call
	_on_value_changed(value)
	force_update_control()
	
	return hbox

func create_value_node() -> Label:
	value_node = Label.new()
	value_node.custom_minimum_size = Vector2(64,0)
	value_node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value_node.add_theme_font_override("font", Global.theme.get_font(ThemeManager.FontType.BODY_ITALIC))
	value_node.modulate.a = 0.66
	return value_node

func create_label_node() -> Label:
	label_node = Label.new()
	label_node.set_text(get_label_sanitized())
	label_node.custom_minimum_size = Vector2(348, 0)
	label_node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label_node

func get_default() -> Variant:
	return convert_string_to_variant_value(default)

static func convert_string_to_variant_value(s:String) -> Variant:
	if s == "": return null
	if s.to_lower().strip_edges(true, true) == "true": return true
	if s.to_lower().strip_edges(true, true) == "false": return false
	if s.is_valid_int(): return int(s)
	if s.is_valid_float(): return float(s)
	if s.is_valid_html_color(): return Color(s)
	return s

static func convert_variant_value_to_string(v:Variant) -> String:
	if v is Color: v = v.to_html()
	return str(v)

func set_default(v:Variant) -> void:
	default = convert_variant_value_to_string(v)

func force_update_control() -> void:
	control_node.set_meta("forced_update", true)
	if (control_node is CheckBox) or (control_node is CheckButton):
		control_node.button_pressed = value
	if control_node is HSlider:
		control_node.value = value
	if control_node is OptionButton:
		# @NOTE: this relies on the fact that items are added by just iterating through options in order, so index found this way matches the text string we want
		control_node.select(options.find(value))
	if control_node is ColorPickerButton:
		control_node.color = Color(value)
	control_node.set_meta("forced_update", false)

## Returns true if the current setting's value is equal to its default
func is_value_default() -> bool:
	var def : Variant = get_default()
	var value_string := str(value)
	
	# to prevent floating point errors
	if (value_string.is_valid_int() or value_string.is_valid_float()): 
		return absf(float(value) - float(def)) <= 0.03
	
	# @NOTE: by moving it to a string we can check for equality between objects (like Color) too
	return value_string == str(def)

func _on_value_changed(new_val:Variant) -> void:
	var actually_changed : bool = (value != new_val)
	
	# save the value on ourselves, so it permanently enters into the ConfigFile
	value = new_val
	update_display_value()
	Global.state.save_value(self)
	
	if reset_btn:
		reset_btn.set_visible(not is_value_default())
	
	# update the value in the global config, if it exists
	# @NOTE: this must come BEFORE the callback, as that relies on all information being set
	if key in Global.config:
		Global.config[key] = new_val
	if key in Global.config_system:
		Global.config_system[key] = new_val
	
	# trigger instant modifications on change, if callback set
	run_custom_callback(new_val)
	
	if actually_changed:
		if Global.input and needs_input_refresh:
			Global.input.refresh_button_selection()
		if Global.theme and needs_theme_refresh:
			Global.theme.refresh()

# we basically just create a new GDScript with the custom code as the body
# then add it to the tree and run it
func run_custom_callback(val:Variant) -> void:
	if not callback: return
	
	var source_code := """
@warning_ignore_start('unused_parameter')
@warning_ignore_start('narrowing_conversion')
func eval(v):
{code}
""".format({ code = indent_callback_string(callback) })
	var script = GDScript.new()
	script.set_source_code(source_code)
	script.reload()
	
	var ref = RefCounted.new()
	ref.set_script(script)
	ref.eval(val)

func run_custom_initialization() -> void:
	if not callback_init: return
	
	var source_code := """
@warning_ignore_start('unused_parameter')
@warning_ignore_start('narrowing_conversion')
func eval(s):
{code}
""".format({ code = indent_callback_string(callback_init) })
	var script = GDScript.new()
	script.set_source_code(source_code)
	script.reload()
	
	var ref = RefCounted.new()
	ref.set_script(script)
	ref.eval(self)

func indent_callback_string(cb:String) -> String:
	cb = cb.replace("\r", "")
	var callback_lines = cb.split("\n")
	for i in range(callback_lines.size()):
		callback_lines[i] = "\t" + callback_lines[i]
	return "\n".join(callback_lines)

func update_display_value() -> void:
	if not value_node: return
	
	var conv_val : Variant = value
	if type_display == TypeDisplay.FLOAT: conv_val = roundf(value*100.0)/100.0
	if type_display == TypeDisplay.INT: conv_val = roundi(value)
	if type_display == TypeDisplay.VOLUME: conv_val = str(roundf(linear_to_db(value)))
	if type_display == TypeDisplay.BOOL: conv_val = "ST_BOOL_TRUE" if value else "ST_BOOL_FALSE"
	if type_display == TypeDisplay.COLOR: conv_val = "#" + Color(value).to_html() # to_html means a hex string
	
	var text_final := str(conv_val) + get_unit()
	value_node.set_text(text_final)

func get_unit() -> String:
	if type_unit == TypeUnit.DECIBELS: return "dB"
	if type_unit == TypeUnit.SECONDS: return "s" 
	if type_unit == TypeUnit.MILLISECONDS: return "ms"
	if type_unit == TypeUnit.PIXELS: return "px"
	return ""
