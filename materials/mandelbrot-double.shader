shader_type canvas_item;

/* This experimental code attempts to emulate double precision. It runs and slows the 
frame rate way down, but does not appear to provide any more resolution for the mandelbrot. */

uniform int   color_scheme = 1;
uniform int   smoothing = 0;

uniform highp float scale = 86566.;
uniform highp vec2  position = vec2(1.256318, -0.378673);
uniform float aspect_ratio = 1.0;

uniform float power = 2.0;
uniform float max_iterations = 400.0;
uniform float bailout = 4.0;

/****** Emulated Double Functions ******/
// https://www.thasler.com/blog/blog/glsl-part2-emu

highp vec2 d_set(highp float a) {
	return vec2(a, 0.0);
}

// Add: res = ds_add(a, b) => res = a + b	
highp vec2 d_add (highp vec2 da, highp vec2 db) {
	highp vec2 dc;
	highp float t1, t2, e;

	t1 = da.x + db.x;
	e = t1 - da.x;
	t2 = ((db.x - e) + (da.x - (t1 - e))) + da.y + db.y;

	dc.x = t1 + t2;
	dc.y = t2 - (dc.x - t1);
	return dc;
}	
	
// Substract: res = ds_sub(a, b) => res = a - b
highp vec2 d_sub (highp vec2 da, highp vec2 db) {
	highp vec2 dc;
	highp float e, t1, t2;

 	t1 = da.x - db.x;
 	e = t1 - da.x;
 	t2 = ((-db.x - e) + (da.x - (t1 - e))) + da.y - db.y;

	dc.x = t1 + t2;
 	dc.y = t2 - (dc.x - t1);
 	return dc;
}

// Compare: res = -1 if a < b
//              = 0 if a == b
//              = 1 if a > b
highp float d_compare(highp vec2 da, highp vec2 db) {
 	if (da.x < db.x) return -1.;
 	else if (da.x == db.x) {
		if (da.y < db.y) return -1.;
		else if (da.y == db.y) return 0.;
		else return 1.;
		}
 	else return 1.;
}

// Multiply: res = ds_mul(a, b) => res = a * b
highp vec2 d_mul (highp vec2 da, highp vec2 db) {
	highp vec2 dc;
	highp float c11, c21, c2, e, t1, t2;
	highp float a1, a2, b1, b2, cona, conb, split = 8193.;

	cona = da.x * split;
	conb = db.x * split;
	a1 = cona - (cona - da.x);
	b1 = conb - (conb - db.x);
	a2 = da.x - a1;
	b2 = db.x - b1;

	c11 = da.x * db.x;
	c21 = a2 * b2 + (a2 * b1 + (a1 * b2 + (a1 * b1 - c11)));

	c2 = da.x * db.y + da.y * db.x;

	t1 = c11 + c2;
	e = t1 - c11;
	t2 = da.y * db.y + ((c2 - e) + (c11 - (t1 - e))) + c21;

	dc.x = t1 + t2;
	dc.y = t2 - (dc.x - t1);

	return dc;
}	
	
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
	
	
	// w = re^i*theta
	// log(w) = log(r) + i*theta
	// w^z = e^z*log(w) = e^z*log(r)+i^theta
	
	// Euler's formula
	// e^i*t = cos t + i sin t
	
	// z^n = w
	// w = r(cos th + i sin th)
	// z angle = th/n
	// z magnitude = nroot(r)
	// z = nrootr * (cos th/n + i sin th/n)
	
	// z^n = r^n(cos n*th + i sin n*th)
	// = r^n*cos(n*th), i r^n * sin(n*th)
	
	/*
	vec2 a = c_pol(base);	// Convert to polar
	
	// Polar Algorithm where [tan theta = z.y/z.x] and [r^2 = z.x^2 + z.y^2]  													
	// Isn't accurate for even powers
	float rn = pow(a.x, ex); // test FPS
	//rn = pow(sqrt(z.x*z.x + z.y*z.y), power);			//^n -> 5-8fps 
	//rn = z.x*z.x + z.y*z.y;							//^2 -> 8-9fps
	vec2 z = vec2(rn * cos(ex*a.y), rn * sin(ex*a.y));	
	return z;//c_rec(z);
	*/
}


/****** Color functions ******/

vec4 getColor(float i) {
	if(color_scheme == 1) {
		/* Sin/Cos creates a smooth wave between 1 and -1, offset from each other. 
		*  You can have 4 evenly distributed offsets from sin, cos, -sin, -cos
		*  (sin(x) +1) / 2 -> changes the wave to go between 0 and 1 with the same frequency, +2../4 will go from 0.5 and 1.0
		*  Calculate full cycles with: sin(cycles*6.5*i)   or   (sin(cycles*5.4*i)+1.0)/2.0   or   (cos(cycles*3.8*i)+1.0)/2.0
		*/
		return vec4(	(sin(10.8*i)+1.0)/2.0, 
	                   	(sin(8.1*i)+1.0)/2.0,
	                    (sin(5.4*i)+1.0)/2.0,
	                    1.0);	
	}
	if(color_scheme == 2) 
		return vec4(i, 0.0, 0.0, 1.0);
	if(color_scheme == 3) 
		return vec4(0.0, i, 0.0, 1.0);	
	else //if(color_scheme == 4) 
		return vec4(0.0, 0.0, i, 1.0);

}


/****** Fragement Main ******/
// Mandelbrot is z^2+C	

void fragment() {	
	float i = 0.0;
	highp vec2 c_d1 = vec2(0.0, 0.0);
	highp vec2 c_d2 = vec2(0.0, 0.0);
	vec4 color;
	
	c_d1 = d_set(aspect_ratio * (UV.x - 0.5) / scale - position.x);
	c_d2 = d_set((UV.y - 0.5) / scale + position.y);

	highp vec2 z_d1 = c_d1;
	highp vec2 z_d2 = c_d2;
	
	vec2 bailout_d = d_set(bailout*bailout);
	vec2 power_d = d_set(power);
	vec2 tmp;
		
	//if(power==2.0)
		while( i<max_iterations && // length(z) <= bailout ) { 
			d_compare(d_add(d_mul(z_d1, z_d1), d_mul(z_d2, z_d2)), bailout_d)<=0.0 ) {
			tmp = z_d1;
			z_d1 = d_add(d_sub(d_mul(z_d1, z_d1), d_mul(z_d2, z_d2)), c_d1);
			z_d2 = d_add(d_mul(d_mul(z_d2, tmp), power_d), c_d2);
			
						
			//z = vec2(z.x*z.x - z.y*z.y, power*z.x*z.y) + c;		//20fps
			i++;		
		}
	/*else
		while( i<max_iterations && length(z) <= bailout ) { 
			z = c_pow(z, power) + c;							//6-7fps				
			i++;	
		}
	*/
	
	if (i >= max_iterations) 
		color = vec4(0.0, 0.0, 0.0, 1.0);
	else { 
		//if(smoothing==1) i -= log(log(length(z))) / log(power);		
		color = getColor(i/max_iterations);
	}
		
	COLOR = color;
}

