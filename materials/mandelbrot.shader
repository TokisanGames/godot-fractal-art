shader_type canvas_item;

uniform int   color_method = 1;
uniform int   smoothing = 0;
uniform vec4  gradient_start : hint_color = vec4(0.18, 0., 0.45, 1.);
uniform vec4  gradient_end : hint_color = vec4(1., 1., 0., 1.);
uniform vec4  gradient_accent : hint_color = vec4(1., 1., 0., 1.);
uniform float accent_position = 0.65;
uniform float accent_width = 0.34;
uniform float red_frequency=1.6615;
uniform float green_frequency=1.246;
uniform float blue_frequency=0.831;
uniform float red_phase=6.3;
uniform float green_phase=6.3;
uniform float blue_phase=6.3;


uniform highp float scale = 0.36;
uniform highp vec2  position = vec2(0.75, 0.0);
uniform float aspect_ratio = 1.778;

uniform float power = 2.0;
uniform float iterations = 50.0;
uniform float escape = 4.0;


/****** Math functions ******/
 
highp vec2 c_pol(highp vec2 c) { 	// Convert from rectangular to polar
	highp float radius = length(c);
	highp float theta = atan(c.y, c.x);
	return vec2(radius, theta);
}

highp vec2 c_rec(highp vec2 c) { 	// Convert from rectangular to Polar
	highp float radius = abs(c.x);
	highp float theta = c.y;
	highp float a = radius * cos(theta);
	highp float b = radius * sin(theta);
	return vec2(a, b);
}


highp vec2 c_pow(highp vec2 base, highp float ex) { // Calculate base ^ exponent
	highp vec2  b = c_pol(base);
	return c_rec( vec2(pow(b.x, ex), b.y*ex) );
}


/****** Color functions ******/

vec4 alpha_blend (vec4 top, vec4 bot) {	
	return vec4( top.r * top.a + bot.r * bot.a * (1. - top.a),
				 top.g * top.a + bot.g * bot.a * (1. - top.a),
				 top.b * top.a + bot.b * bot.a * (1. - top.a),
				 1.0);
} 


vec4 getColor(float i) {
	if(color_method == 2) {
		vec4 ramp;
		vec4 accent;

		// Create gradient
		ramp = mix(gradient_start, gradient_end, i); 	
		
		//gaussian formula ae^( -(x-b)^2 / 2c^2 )
		// a = curve's peak = 1.0
		// b = center of peak position
		// c = standard deviation which controls width of bell
		
		float gaussianx = exp( -((i-accent_position)*(i-accent_position)) / (2.*accent_width*accent_width) );
		accent = vec4(gradient_accent.r*gaussianx,
					  gradient_accent.g*gaussianx,
					  gradient_accent.b*gaussianx,
					  gaussianx);
		
		return alpha_blend(accent, ramp);
	}
	
	else {
		/* Sin/Cos creates a smooth wave between 1 and -1, offset from each other. 
		*  You can have 4 evenly distributed offsets from sin, cos, -sin, -cos
		*  (sin(x) +1) / 2 -> changes the wave to go between 0 and 1 with the same frequency, +2../4 will go from 0.5 and 1.0
		*  Calculate full cycles with: sin(cycles*6.5*i)   or   (sin(cycles*5.4*i)+1.0)/2.0   or   (cos(cycles*3.8*i)+1.0)/2.0
		*/
       	return vec4( (sin(red_frequency*6.5*i + red_phase) +1.0)/2.0,
	       			 (sin(green_frequency*6.5*i + green_phase) +1.0)/2.0,
       				 (sin(blue_frequency*6.5*i + blue_phase) + 1.0)/2.0,
					 1.);
	}
}


/****** Fragement Main ******/
// Mandelbrot is z^2+C	

void fragment() {
	float i = 0.0;
	
	highp vec2 c;
	c.x = aspect_ratio * (UV.x - 0.5) / scale - position.x;
	c.y = (UV.y - 0.5) / scale + position.y;

	highp vec2 z = c;
		
	if(power==2.0)
		while( i<iterations && length(z) <= escape ) { 
			z = vec2(z.x*z.x - z.y*z.y, power*z.x*z.y) + c;		//20fps
			i++;		
		}
	else
		while( i<iterations && length(z) <= escape ) { 
			z = c_pow(z, power) + c;							//6-7fps				
			i++;	
		}

		
	vec4 color;
	
	if (i >= iterations) 
		color = vec4(0.0, 0.0, 0.0, 1.0);
	else { 
		if(smoothing==1 && power>1.) i -= log(log(length(z))) / log(power);		
		color = getColor(i/iterations);
	}
		
	COLOR = color;
}

