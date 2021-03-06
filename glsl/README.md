# GLSL shaders

This is a collection of pure GLSL shaders and functions I've written.

A significant chunk are "general purpose" functions that are commonly used.

## General purpose files (in some order of usefulness)

|Name                    |Description                                              |Category       |
|------------------------|---------------------------------------------------------|---------------|
|gamma_correct.glsl      |sRGB, Rec.709, Rec.2020 transfer functions.              |Colour Spaces  |
|luma.glsl               |sRGB, Rec.709 luminosity approximations.                 |Colour Spaces  |
|hsv.glsl *(TBD)*        |hsv-rgb, rgb-hsv functions, for HSV colour space         |Colour Spaces  |
|simple_tonecurve.glsl   |A fix. 3 point tonecurve, for simple colour correction   |Grading        |
|fast_mipmap_bloom.glsl  |A very simple bloom function for mipmapped images        |Effect         |

## Specific stuff (in order of "cool")

*TBD.* 

## Documentation

The files themselves are pretty well documented but web docs are planned.

## Headers?
The current idea is that a file can be dropped into most projects without 
problems. So I omitted headers as many people just compile their shaders as a 
big blob even though some has OpenGL wrappers with support for it.

## License
All the .glsl-files are **MIT-licensed**.


*For specific licensing contact the author.*