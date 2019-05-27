# Godot Fractals

This project generates the Mandelbrot and Julia fractal sets using shaders and the Godot Engine.

What sets this fractal generator apart from others is that you can control the julia seed with mouse movement and watch some interesting visual effects.

![Julia screenshot](screenshots/julia1.gif)
![Julia screenshot](screenshots/julia2.gif)
![Mandelbrot screenshot](screenshots/mandelbrot1.gif)

## How to use
All the keys are in the menu. Here are some highlights:
* Pan with click+drag, zoom with the wheel.
* On the Julia set, press 's' to change the seed with mouse control to get the cool animated effects. Press 's' to lock the seed in place.
* Escape will show and hide the menu.

![Menu](screenshots/menu.gif)



## Limitations
* You can only zoom in so far before you start seeing blocky results. Godot only supports single precision shaders currently. Perhaps when they support double precision, we can zoom in further. I attempted to implement double precision, and while this tremendously lowered my framerate, it did not increase the resolution. The files are 
