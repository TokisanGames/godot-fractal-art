extends Node

# TODO 

# - Code cleanup / Bugs -

# - Features -

# Auto zoom (z)
# Color cycle (c)
# Save screenshots (ctrl+w)
# Consider merging shader algorithms
# Smooth shading for negative powers
# Add more fractal formulas: Sierpinski carpet, Convergent, newton, http://www.fractalsciencekit.com/types/classic.htm
# -- Emulate high precision, but still doesn't work and super slow


const NONE:int		= 0x0
const SHIFT:int 	= 0x1
const CONTROL:int	= 0x2
const ALT:int 		= 0x4

const JULIA = preload("res://materials/julia.material")
const MANDELBROT = preload("res://materials/mandelbrot.material")

var mouse_sets_seed:bool = false
var mouse_sets_position:bool = false

onready var screen_size:Vector2 = get_viewport().get_visible_rect().size

	
func _ready() -> void:
	get_viewport().connect("size_changed", self, "update_aspect_ratio")
	update_aspect_ratio()


func _process(delta) -> void:
	$UI.find_node("FPS").text = String(Engine.get_frames_per_second())


func set_fractal(fractal:int) -> void:
	if(fractal==1):
		$Panel.set_material(MANDELBROT)
	if(fractal==2):
		$Panel.set_material(JULIA)
	update_aspect_ratio()


func update_aspect_ratio() -> void:
	var vs:Vector2 = get_viewport().get_size()
	$Panel.material.set_shader_param("aspect_ratio", vs.x/vs.y)


func checkKey(event, key, modifier=NONE) -> bool:
	if event is InputEventKey and event.pressed:
		if event.scancode == key:
			if modifier & SHIFT && event.shift:
				return true
			elif modifier & CONTROL && event.control:
				return true
			elif modifier & ALT && event.alt:
				return true
			elif modifier==NONE:
				return true
	return false


func _input(event) -> void:
	var i:float

	if(event is InputEventMouseMotion):
		if(mouse_sets_seed && $Panel.material.get_shader_param("seed")):
			var jseed:Vector2
			var mouse_speed:float = 0.25
			jseed = $Panel.material.get_shader_param("seed")
			if(Input.is_key_pressed(KEY_SHIFT)): mouse_speed = 0.0833
			if(Input.is_key_pressed(KEY_CONTROL)): mouse_speed = 0.025
			jseed += mouse_speed * event.relative / (screen_size.y * $Panel.material.get_shader_param("scale"))
			if(jseed.x==0.0 && jseed.y==0.0): jseed.y=.0001
			$Panel.material.set_shader_param("seed", jseed)
			$UI.seedX_label.text = String(jseed.x)
			$UI.seedY_label.text = String(jseed.y)
			
		if(mouse_sets_position):
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			move /= (screen_size.y * $Panel.material.get_shader_param("scale"))
			move += $Panel.material.get_shader_param("position")
			$Panel.material.set_shader_param("position", move)
			$UI.find_node("PositionX").text = String(move.x)
			$UI.find_node("PositionY").text = String(move.y)


	elif(event is InputEventMouseButton && event.button_index == BUTTON_LEFT):
		if(event.pressed):
			var PP = $UI.find_node("PickPanel")
			if( !( ($UI.visible && event.position.x <= $UI.rect_size.x && event.position.y <= $UI.rect_size.y) ||
				(PP.visible && event.position.x <= $UI.rect_size.x + PP.rect_size.x && event.position.y <= PP.rect_size.y) ) ):
				# If mouse clicked and not within the $UI if visible
				mouse_sets_position = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			mouse_sets_position = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
	elif(event.is_action_pressed("wheel_up")):
		i = $Panel.material.get_shader_param("scale") * 1.1
		$Panel.material.set_shader_param("scale", i)
		$UI.find_node("Scale").text = String(i)
				
		# At scale 1, fractal position ranges from -/+ (0.9, 0.5). Not sure why.
		# Calculate % of mouse position to window size, convert that to -0.9 to 0.9, -0.5 to 0.5
		# Reduce by scale. 
		# Then reduce another 10x and minus instead of add position. Not sure why, but it works perfectly
		var v_size:Vector2 = get_viewport().size
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		mouse_pos = Vector2( 0.9 * (2*mouse_pos.x/v_size.x - 1) , 0.5 * ((2-(2*mouse_pos.y/v_size.y))-1) )
		var fractal_pos:Vector2 = $Panel.material.get_shader_param("position")
		var fractal_scale:float = $Panel.material.get_shader_param("scale")
		fractal_pos -= mouse_pos/fractal_scale/10
		$Panel.material.set_shader_param("position", fractal_pos)
		$UI.find_node("PositionX").text = String(fractal_pos.x)
		$UI.find_node("PositionY").text = String(fractal_pos.y)
	

	elif(event.is_action_pressed("wheel_down")):
		i = $Panel.material.get_shader_param("scale") / 1.1
		$Panel.material.set_shader_param("scale", i)
		$UI.find_node("Scale").text = String(i)

	
	elif(checkKey(event, KEY_S)):
		if($Panel.material.get_shader_param("seed")):
			mouse_sets_seed = !mouse_sets_seed
			if(mouse_sets_seed): Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		
	elif(checkKey(event, KEY_P, SHIFT)):
		i = $Panel.material.get_shader_param("power") - 1
		if(i==0): i=-1
		$Panel.material.set_shader_param("power", i)
		$UI.find_node("Power").text = String(i)


	elif(checkKey(event, KEY_P)):
		i = $Panel.material.get_shader_param("power") + 1
		if(i==0): i=1
		$Panel.material.set_shader_param("power", i)
		$UI.find_node("Power").text = String(i)


	elif(checkKey(event, KEY_I, SHIFT)):
		i = $Panel.material.get_shader_param("iterations") - 1
		if(i>=2):
			$Panel.material.set_shader_param("iterations", i)
			$UI.find_node("Iterations").text = String(i)


	elif(checkKey(event, KEY_I)):
		i = $Panel.material.get_shader_param("iterations") + 1
		$Panel.material.set_shader_param("iterations", i)
		$UI.find_node("Iterations").text = String(i)


	elif(checkKey(event, KEY_G)):
		var smoothing = $Panel.material.get_shader_param("smoothing")
		$Panel.material.set_shader_param("smoothing", !smoothing)
		$UI.find_node("Smoothing").pressed = $Panel.material.get_shader_param("smoothing")


	elif(checkKey(event, KEY_F)):
		$UI.find_node("FullScreen").pressed = !OS.window_fullscreen
		OS.window_fullscreen = OS.window_fullscreen 


	elif(checkKey(event, KEY_ESCAPE) or
		(event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed)):
		$UI.visible = ! $UI.visible
		$UI.find_node("Mandelbrot Button").grab_focus()

		
	elif(checkKey(event, KEY_ENTER)):
		$UI.clear_focus()


	elif(checkKey(event, KEY_Q, CONTROL)):
		get_tree().quit()

		
