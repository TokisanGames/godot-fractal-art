extends Control


@onready var seedX_label = find_child("SeedX")
@onready var seedY_label = find_child("SeedY")
var shader_mat: ShaderMaterial

var picker_name:String = ""

	
func _ready():
	await get_parent().ready
	update_UI()
	find_child("Julia Button").grab_focus()

	
func set_color_scheme() -> void:
	shader_mat.set_shader_parameter("color_method", find_child("ColorMethod").button_pressed);
	shader_mat.set_shader_parameter("red_frequency", find_child("RedFrequency").value);
	shader_mat.set_shader_parameter("red_phase", find_child("RedPhase").value); 
	shader_mat.set_shader_parameter("green_frequency", find_child("GreenFrequency").value); 
	shader_mat.set_shader_parameter("green_phase", find_child("GreenPhase").value); 
	shader_mat.set_shader_parameter("blue_frequency", find_child("BlueFrequency").value); 
	shader_mat.set_shader_parameter("blue_phase", find_child("BluePhase").value); 
	shader_mat.set_shader_parameter("gradient_start", find_child("GStart").color); 
	shader_mat.set_shader_parameter("gradient_end", find_child("GEnd").color); 
	shader_mat.set_shader_parameter("gradient_accent", find_child("GAccent").color); 
	shader_mat.set_shader_parameter("accent_position", find_child("AccentPosition").value); 
	shader_mat.set_shader_parameter("accent_width", find_child("AccentWidth").value); 
	shader_mat.set_shader_parameter("smoothing", find_child("Smoothing").button_pressed); 
	

func update_UI() -> void:
	find_child("ColorMethod").button_pressed = shader_mat.get_shader_parameter("color_method")
	find_child("RedFrequency").value = shader_mat.get_shader_parameter("red_frequency")
	find_child("RedPhase").value = shader_mat.get_shader_parameter("red_phase")
	find_child("GreenFrequency").value = shader_mat.get_shader_parameter("green_frequency")
	find_child("GreenPhase").value = shader_mat.get_shader_parameter("green_phase")
	find_child("BlueFrequency").value = shader_mat.get_shader_parameter("blue_frequency")
	find_child("BluePhase").value = shader_mat.get_shader_parameter("blue_phase")
	find_child("GStart").color = shader_mat.get_shader_parameter("gradient_start")
	find_child("GEnd").color = shader_mat.get_shader_parameter("gradient_end")
	find_child("GAccent").color = shader_mat.get_shader_parameter("gradient_accent")
	find_child("AccentPosition").value = shader_mat.get_shader_parameter("accent_position")
	find_child("AccentWidth").value = shader_mat.get_shader_parameter("accent_width")
	find_child("Smoothing").button_pressed = shader_mat.get_shader_parameter("smoothing")
	
	find_child("Scale").text = String.num(shader_mat.get_shader_parameter("scale"))
	find_child("PositionX").text = String.num(shader_mat.get_shader_parameter("position").x)
	find_child("PositionY").text = String.num(shader_mat.get_shader_parameter("position").y)
	
	if(shader_mat.get_shader_parameter("seed")):
		find_child("SeedX").text = String.num(shader_mat.get_shader_parameter("seed").x)
		find_child("SeedY").text = String.num(shader_mat.get_shader_parameter("seed").y)
	find_child("Power").text = String.num(shader_mat.get_shader_parameter("power"))
	find_child("Iterations").text = String.num(shader_mat.get_shader_parameter("iterations"))



func clear_focus() -> void :
	#get_tree().call_group("text","release_focus")

	find_child("Scale").release_focus()
	find_child("PositionX").release_focus()
	find_child("PositionY").release_focus()
	find_child("SeedX").release_focus()
	find_child("SeedY").release_focus()
	find_child("Power").release_focus()
	find_child("Iterations").release_focus()


func _on_Mandelbrot_Button_pressed():
	get_parent().set_fractal(1)
	shader_mat = $"../Panel".get_material()
	set_color_scheme()
	update_UI()
	find_child("SeedX").editable = false
	find_child("SeedY").editable = false


func _on_Julia_Button_pressed():
	get_parent().set_fractal(2)
	shader_mat = $"../Panel".get_material()	
	set_color_scheme()
	update_UI()
	find_child("SeedX").editable = true
	find_child("SeedY").editable = true


func _on_FullScreen_toggled(button_pressed):
	get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED


func _on_ColorMethod_toggled(value):
	if(value==true): 
		shader_mat.set_shader_parameter("color_method", 1)
		find_child("RedBlock").hide()
		find_child("GreenBlock").hide()
		find_child("BlueBlock").hide()
		find_child("GradientBlock").show()
		find_child("AccentPosBlock").show()
		find_child("WidthBlock").show()
	else: 
		shader_mat.set_shader_parameter("color_method", 0)
		find_child("RedBlock").show()
		find_child("GreenBlock").show()
		find_child("BlueBlock").show()
		find_child("GradientBlock").hide()
		find_child("AccentPosBlock").hide()
		find_child("WidthBlock").hide()
		

func _on_RedFrequency_value_changed(value):
	shader_mat.set_shader_parameter("red_frequency", value)
	print("Red Frequency: ", value);


func _on_GreenFrequency_value_changed(value):
	shader_mat.set_shader_parameter("green_frequency", value)
	print("Green Frequency: ", value);

	
func _on_BlueFrequency_value_changed(value):
	shader_mat.set_shader_parameter("blue_frequency", value)
	print("Blue Frequency: ", value);


func _on_RedPhase_value_changed(value):
	shader_mat.set_shader_parameter("red_phase", value)
	print("Red Phase: ", value);


func _on_GreenPhase_value_changed(value):
	shader_mat.set_shader_parameter("green_phase", value)
	print("Green Phase: ", value);


func _on_BluePhase_value_changed(value):
	shader_mat.set_shader_parameter("blue_phase", value)
	print("Blue Phase: ", value);


func _on_GStart_gui_input(event):
	pick(event, "GStart")

		
func _on_GEnd_gui_input(event):
	pick(event, "GEnd")


func _on_GAccent_gui_input(event):
	pick(event, "GAccent")

		
func pick(event, name:String) -> void:
	if(event is InputEventMouseButton && event.button_index == MOUSE_BUTTON_LEFT):
		picker_name = name
		find_child("ColorPicker").color = find_child(picker_name).color
		find_child("PickPanel").show()
		

func _on_ColorPicker_color_changed(color):
	find_child(picker_name).color = color
	if(picker_name=="GStart"): shader_mat.set_shader_parameter("gradient_start", color)
	if(picker_name=="GEnd"): shader_mat.set_shader_parameter("gradient_end", color)
	if(picker_name=="GAccent"): shader_mat.set_shader_parameter("gradient_accent", color)
	
	
func _on_ClosePicker_pressed():
	find_child("PickPanel").hide()


func _on_AccentPosition_value_changed(value):
	shader_mat.set_shader_parameter("accent_position", value)


func _on_AccentWidth_value_changed(value):
	shader_mat.set_shader_parameter("accent_width", value)


func _on_Smoothing_toggled(button_pressed):
	shader_mat.set_shader_parameter("smoothing", button_pressed)


func _on_Scale_text_changed(new_text):
	shader_mat.set_shader_parameter("scale", float(new_text))


func _on_PositionX_text_changed(new_text):
	var y = find_child("PositionY").text
	shader_mat.set_shader_parameter("position", Vector2(float(new_text), float(y)))


func _on_PositionY_text_changed(new_text):
	var x = find_child("PositionX").text
	shader_mat.set_shader_parameter("position", Vector2(float(x), float(new_text)))


func _on_SeedX_text_changed(new_text):
	var x = float(new_text)
	var y = float(find_child("SeedX").text)
	if(x==0.0 && y==0.0): x=.0001
	shader_mat.set_shader_parameter("seed", Vector2(x, y))


func _on_SeedY_text_changed(new_text):
	var x = float(find_child("SeedY").text)
	var y = float(new_text)
	if(x==0.0 && y==0.0): y=.0001
	shader_mat.set_shader_parameter("seed", Vector2(x, y))


func _on_Power_text_changed(new_text):
	var value = float(new_text)
	var old_value = shader_mat.get_shader_parameter("power")
	if(old_value<value && value==0): value=1
	if(old_value>value && value==0): value=-1
	shader_mat.set_shader_parameter("power", value)
	find_child("Power").text = new_text
	
	
func _on_Iterations_text_changed(new_text):
	shader_mat.set_shader_parameter("iterations", float(new_text))


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_HideButton_pressed():
	visible = ! visible
	find_child("Mandelbrot Button").grab_focus()
