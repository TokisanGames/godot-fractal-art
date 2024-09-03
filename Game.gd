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

@onready var screen_size:Vector2 = get_viewport().get_visible_rect().size

	
func _ready() -> void:
	get_viewport().connect("size_changed", Callable(self, "update_aspect_ratio"))
	update_aspect_ratio()
	$UI.shader_mat = $Panel.get_material()


func _process(delta) -> void:
	$UI.find_child("FPS").text = String.num(Engine.get_frames_per_second())


func set_fractal(fractal:int) -> void:
	if(fractal==1):
		$Panel.set_material(MANDELBROT)
	if(fractal==2):
		$Panel.set_material(JULIA)
	update_aspect_ratio()


func update_aspect_ratio() -> void:
	var vs:Vector2 = get_viewport().get_size()
	$Panel.material.set_shader_parameter("aspect_ratio", vs.x/vs.y)


func checkKey(event, key, modifier=NONE) -> bool:
	if event is InputEventKey and event.pressed:
		if event.keycode == key:
			if modifier & SHIFT && event.shift_pressed:
				return true
			elif modifier & CONTROL && event.control_pressed:
				return true
			elif modifier & ALT && event.alt_pressed:
				return true
			elif modifier==NONE:
				return true
	return false


func _input(event) -> void:
	var i:float

	if(event is InputEventMouseMotion):
		if(mouse_sets_seed && $Panel.material.get_shader_parameter("seed")):
			var jseed:Vector2
			var mouse_speed:float = 0.25
			jseed = $Panel.material.get_shader_parameter("seed")
			if(Input.is_key_pressed(KEY_SHIFT)): mouse_speed = 0.0833
			if(Input.is_key_pressed(KEY_CTRL)): mouse_speed = 0.025
			jseed += mouse_speed * event.relative / (screen_size.y * $Panel.material.get_shader_parameter("scale"))
			if(jseed.x==0.0 && jseed.y==0.0): jseed.y=.0001
			$Panel.material.set_shader_parameter("seed", jseed)
			$UI.seedX_label.text = String.num(jseed.x)
			$UI.seedY_label.text = String.num(jseed.y)
			
		if(mouse_sets_position):
			var move:Vector2 = Vector2(event.relative.x, -event.relative.y) 
			move /= (screen_size.y * $Panel.material.get_shader_parameter("scale"))
			move += $Panel.material.get_shader_parameter("position")
			$Panel.material.set_shader_parameter("position", move)
			$UI.find_child("PositionX").text = String.num(move.x)
			$UI.find_child("PositionY").text = String.num(move.y)


	elif(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		if(event.pressed):
			var PP = $UI.find_child("PickPanel")
			if( !( ($UI.visible && event.position.x <= $UI.size.x && event.position.y <= $UI.size.y) ||
				(PP.visible && event.position.x <= $UI.size.x + PP.size.x && event.position.y <= PP.size.y) ) ):
				# If mouse clicked and not within the $UI if visible
				mouse_sets_position = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			mouse_sets_position = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
		
	elif(event.is_action_pressed("wheel_up")):
		i = $Panel.material.get_shader_parameter("scale") * 1.1
		$Panel.material.set_shader_parameter("scale", i)
		$UI.find_child("Scale").text = String.num(i)
				
		# At scale 1, fractal position ranges from -/+ (0.9, 0.5). Not sure why.
		# Calculate % of mouse position to window size, convert that to -0.9 to 0.9, -0.5 to 0.5
		# Reduce by scale. 
		# Then reduce another 10x and minus instead of add position. Not sure why, but it works perfectly
		var v_size:Vector2 = get_viewport().size
		var mouse_pos:Vector2 = get_viewport().get_mouse_position()
		mouse_pos = Vector2( 0.9 * (2*mouse_pos.x/v_size.x - 1) , 0.5 * ((2-(2*mouse_pos.y/v_size.y))-1) )
		var fractal_pos:Vector2 = $Panel.material.get_shader_parameter("position")
		var fractal_scale:float = $Panel.material.get_shader_parameter("scale")
		fractal_pos -= mouse_pos/fractal_scale/10
		$Panel.material.set_shader_parameter("position", fractal_pos)
		$UI.find_child("PositionX").text = String.num(fractal_pos.x)
		$UI.find_child("PositionY").text = String.num(fractal_pos.y)
	

	elif(event.is_action_pressed("wheel_down")):
		i = $Panel.material.get_shader_parameter("scale") / 1.1
		$Panel.material.set_shader_parameter("scale", i)
		$UI.find_child("Scale").text = String.num(i)

	
	elif(checkKey(event, KEY_S)):
		if($Panel.material.get_shader_parameter("seed")):
			mouse_sets_seed = !mouse_sets_seed
			if(mouse_sets_seed): Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else: Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		
	elif(checkKey(event, KEY_P, SHIFT)):
		i = $Panel.material.get_shader_parameter("power") - 1
		if(i==0): i=-1
		$Panel.material.set_shader_parameter("power", i)
		$UI.find_child("Power").text = String.num(i)


	elif(checkKey(event, KEY_P)):
		i = $Panel.material.get_shader_parameter("power") + 1
		if(i==0): i=1
		$Panel.material.set_shader_parameter("power", i)
		$UI.find_child("Power").text = String.num(i)


	elif(checkKey(event, KEY_I, SHIFT)):
		i = $Panel.material.get_shader_parameter("iterations") - 1
		if(i>=2):
			$Panel.material.set_shader_parameter("iterations", i)
			$UI.find_child("Iterations").text = String.num(i)


	elif(checkKey(event, KEY_I)):
		i = $Panel.material.get_shader_parameter("iterations") + 1
		$Panel.material.set_shader_parameter("iterations", i)
		$UI.find_child("Iterations").text = String.num(i)


	elif(checkKey(event, KEY_G)):
		var smoothing = $Panel.material.get_shader_parameter("smoothing")
		$Panel.material.set_shader_parameter("smoothing", !smoothing)
		$UI.find_child("Smoothing").button_pressed = $Panel.material.get_shader_parameter("smoothing")


	elif(checkKey(event, KEY_F)):
		$UI.find_child("FullScreen").button_pressed = !((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)) ) else Window.MODE_WINDOWED


	elif(checkKey(event, KEY_ESCAPE) or
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed)):
		$UI.visible = ! $UI.visible
		$UI.find_child("Mandelbrot Button").grab_focus()

		
	elif(checkKey(event, KEY_ENTER)):
		$UI.clear_focus()


	elif(checkKey(event, KEY_Q, CONTROL)):
		get_tree().quit()

		
