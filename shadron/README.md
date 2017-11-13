# Shadron shaders

Shaders written for the program Shadron.

Many of the shaders have analogues in the `glsl` folder. Those generally 
showcase the functionality for the given file in the GLSL-folder.

## Noteworthy shaders (in order of "cool")

### crt.shadron

A work-in-progress CRT shader, it does a decent effect but has a long way to go to authenticity.

### tracer1.shadron

A work-in-progress path tracer. Currently does depth of field and diffuse spheres only.

Progressively updates as you run it. The sample count is stored in the alpha channel and another
feedback buffer appends them. The final image is the aggregate RBG values divided by the sample count.

*Note:* You need to "refresh" the script after parameter changes, the buffers won't clear by themselves.