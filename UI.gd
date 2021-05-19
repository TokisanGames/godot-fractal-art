extends Control


onready var seedX_label = find_node("SeedX")
onready var seedY_label = find_node("SeedY")
onready var shader_mat = get_node("../Panel").get_material()

var picker_name:String = ""

	
func _ready():	
	update_UI()
	find_node("Julia Button").grab_focus()

	
func set_color_scheme() -> void:
	shader_mat.set_shader_param("color_method", find_node("ColorMethod").value);
	shader_mat.set_shader_param("red_frequency", find_node("RedFrequency").value);
	shader_mat.set_shader_param("red_phase", find_node("RedPhase").value); 
	shader_mat.set_shader_param("green_frequency", find_node("GreenFrequency").value); 
	shader_mat.set_shader_param("green_phase", find_node("GreenPhase").value); 
	shader_mat.set_shader_param("blue_frequency", find_node("BlueFrequency").value); 
	shader_mat.set_shader_param("blue_phase", find_node("BluePhase").value); 
	shader_mat.set_shader_param("gradient_start", find_node("GStart").color); 
	shader_mat.set_shader_param("gradient_end", find_node("GEnd").color); 
	shader_mat.set_shader_param("gradient_accent", find_node("GAccent").color); 
	shader_mat.set_shader_param("accent_position", find_node("AccentPosition").value); 
	shader_mat.set_shader_param("accent_width", find_node("AccentWidth").value); 
	shader_mat.set_shader_param("smoothing", find_node("Smoothing").pressed); 
	

func update_UI() -> void:
	find_node("ColorMethod").value = shader_mat.get_shader_param("color_method")
	find_node("RedFrequency").value = shader_mat.get_shader_param("red_frequency")
	find_node("RedPhase").value = shader_mat.get_shader_param("red_phase")
	find_node("GreenFrequency").value = shader_mat.get_shader_param("green_frequency")
	find_node("GreenPhase").value = shader_mat.get_shader_param("green_phase")
	find_node("BlueFrequency").value = shader_mat.get_shader_param("blue_frequency")
	find_node("BluePhase").value = shader_mat.get_shader_param("blue_phase")
	find_node("GStart").color = shader_mat.get_shader_param("gradient_start")
	find_node("GEnd").color = shader_mat.get_shader_param("gradient_end")
	find_node("GAccent").color = shader_mat.get_shader_param("gradient_accent")
	find_node("AccentPosition").value = shader_mat.get_shader_param("accent_position")
	find_node("AccentWidth").value = shader_mat.get_shader_param("accent_width")
	find_node("Smoothing").pressed = shader_mat.get_shader_param("smoothing")
	
	find_node("Scale").text = String(shader_mat.get_shader_param("scale"))
	find_node("PositionX").text = String(shader_mat.get_shader_param("position").x)
	find_node("PositionY").text = String(shader_mat.get_shader_param("position").y)
	
	if(shader_mat.get_shader_param("seed")):
		find_node("SeedX").text = String(shader_mat.get_shader_param("seed").x)
		find_node("SeedY").text = String(shader_mat.get_shader_param("seed").y)
	find_node("Power").text = String(shader_mat.get_shader_param("power"))
	find_node("Iterations").text = String(shader_mat.get_shader_param("iterations"))



func clear_focus() -> void :
	#get_tree().call_group("text","release_focus")

	find_node("Scale").release_focus()
	find_node("PositionX").release_focus()
	find_node("PositionY").release_focus()
	find_node("SeedX").release_focus()
	find_node("SeedY").release_focus()
	find_node("Power").release_focus()
	find_node("Iterations").release_focus()


func _on_Mandelbrot_Button_pressed():
	get_parent().set_fractal(1)
	shader_mat = $"../Panel".get_material()
	set_color_scheme()
	update_UI()
	find_node("SeedX").editable = false
	find_node("SeedY").editable = false


func _on_Julia_Button_pressed():
	get_parent().set_fractal(2)
	shader_mat = $"../Panel".get_material()	
	set_color_scheme()
	update_UI()
	find_node("SeedX").editable = true
	find_node("SeedY").editable = true


func _on_FullScreen_toggled(button_pressed):
	OS.set_window_fullscreen(!OS.is_window_fullscreen())


func _on_ColorMethod_value_changed(value):
	shader_mat.set_shader_param("color_method", value)
	if(value==2): 
		find_node("RedBlock").hide()
		find_node("GreenBlock").hide()
		find_node("BlueBlock").hide()
		find_node("GradientBlock").show()
		find_node("AccentPosBlock").show()
		find_node("WidthBlock").show()
	else: 
		find_node("RedBlock").show()
		find_node("GreenBlock").show()
		find_node("BlueBlock").show()
		find_node("GradientBlock").hide()
		find_node("AccentPosBlock").hide()
		find_node("WidthBlock").hide()
		

func _on_RedFrequency_value_changed(value):
	shader_mat.set_shader_param("red_frequency", value)
	print("Red Frequency: ", value);


func _on_GreenFrequency_value_changed(value):
	shader_mat.set_shader_param("green_frequency", value)
	print("Green Frequency: ", value);

	
func _on_BlueFrequency_value_changed(value):
	shader_mat.set_shader_param("blue_frequency", value)
	print("Blue Frequency: ", value);


func _on_RedPhase_value_changed(value):
	shader_mat.set_shader_param("red_phase", value)
	print("Red Phase: ", value);


func _on_GreenPhase_value_changed(value):
	shader_mat.set_shader_param("green_phase", value)
	print("Green Phase: ", value);


func _on_BluePhase_value_changed(value):
	shader_mat.set_shader_param("blue_phase", value)
	print("Blue Phase: ", value);


func _on_GStart_gui_input(event):
	pick(event, "GStart")

		
func _on_GEnd_gui_input(event):
	pick(event, "GEnd")


func _on_GAccent_gui_input(event):
	pick(event, "GAccent")

		
func pick(event, name:String) -> void:
	if(event is InputEventMouseButton && event.button_index == BUTTON_LEFT):
		picker_name = name
		find_node("ColorPicker").color = find_node(picker_name).color
		find_node("PickPanel").show()
		

func _on_ColorPicker_color_changed(color):
	find_node(picker_name).color = color
	if(picker_name=="GStart"): shader_mat.set_shader_param("gradient_start", color)
	if(picker_name=="GEnd"): shader_mat.set_shader_param("gradient_end", color)
	if(picker_name=="GAccent"): shader_mat.set_shader_param("gradient_accent", color)
	
	
func _on_ClosePicker_pressed():
	find_node("PickPanel").hide()


func _on_AccentPosition_value_changed(value):
	shader_mat.set_shader_param("accent_position", value)


func _on_AccentWidth_value_changed(value):
	shader_mat.set_shader_param("accent_width", value)


func _on_Smoothing_toggled(button_pressed):
	shader_mat.set_shader_param("smoothing", button_pressed)


func _on_Scale_text_changed(new_text):
	shader_mat.set_shader_param("scale", float(new_text))


func _on_PositionX_text_changed(new_text):
	var y = find_node("PositionY").text
	shader_mat.set_shader_param("position", Vector2(float(new_text), float(y)))


func _on_PositionY_text_changed(new_text):
	var x = find_node("PositionX").text
	shader_mat.set_shader_param("position", Vector2(float(x), float(new_text)))


func _on_SeedX_text_changed(new_text):
	var x = float(new_text)
	var y = float(find_node("SeedX").text)
	if(x==0.0 && y==0.0): x=.0001
	shader_mat.set_shader_param("seed", Vector2(x, y))


func _on_SeedY_text_changed(new_text):
	var x = float(find_node("SeedY").text)
	var y = float(new_text)
	if(x==0.0 && y==0.0): y=.0001
	shader_mat.set_shader_param("seed", Vector2(x, y))


func _on_Power_text_changed(new_text):
	var value = float(new_text)
	var old_value = shader_mat.get_shader_param("power")
	if(old_value<value && value==0): value=1
	if(old_value>value && value==0): value=-1
	shader_mat.set_shader_param("power", value)
	find_node("Power").text = new_text
	
	
func _on_Iterations_text_changed(new_text):
	shader_mat.set_shader_param("iterations", float(new_text))


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_HideButton_pressed():
	visible = ! visible
	find_node("Mandelbrot Button").grab_focus()
