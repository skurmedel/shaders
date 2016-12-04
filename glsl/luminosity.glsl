/*
    Luminosity calculations. Use these functions to correctly calculate 
    the luminosity of a a colour for different colour spaces.

    You can also use the appropriate functions to partially desaturate a colour.
    
    The following standards are supported (gamma_correct.glsl for more info):

        - "sRGB"        IEC 61966-2-1:1999
        - "Rec.709"     ITU-R Recommendation BT.709
    
    The following defines can be used to filter out standards not needed.
        
        LUMINOSITY_NO_REC709_SUPPORT
    
################################################################################
    NOTE: WHEN USING THESE ROUTINES, IT ASSUMED YOU ARE IN LINEAR SPACE.
          USE THE ROUTINES IN gamma_correct.glsl IF YOU NEED.

          CALCULATING THE LUMINOSITY IN GAMMA CORRECTED SPACE WILL NOT GIVE THE
          CORRECT RESULTS (ESPECIALLY FOR DARK BLUES ETC.) 
################################################################################
*/

const vec3 SRGB_Y_VALUES = vec3(0.2126, 0.7152, 0.0722);

/*
    Calculates the luminosity of a sRGB RGB triplet. 

    The (CIE) Y values used are: 0.2126, 0.7152, 0.0722.
*/ 
float srgb_luminosity(in vec3 rgb)
{
    return rgb.r * SRGB_Y_VALUES.r
         + rgb.g * SRGB_Y_VALUES.g
         + rgb.b * SRGB_Y_VALUES.b;
}

/*
    Desaturates or increases saturation of a sRGB RGB triplet.

    Values of x between 0 and 1 functions as a desaturation "slider".

    x < 0 or x > 1 increases saturation and might push channels outside [0,1].
*/
vec3 srgb_saturation(in vec3 rgb, in lowp float x)
{
    return mix(srgb_luminosity(rgb) * vec3(1), rgb, x);
}

#ifdef LUMINOSITY_NO_REC709_SUPPORT

/*
    As you can see here, Rec.709 use the same Y values and as such we can use 
    the sRGB luminosity functions. 

    Note! The gamma is not the same! So you must still make sure you are using 
    a Rec.709 gamma correct workflow.
*/ 
const vec3 REC709_Y_VALUES = SRGB_Y_VALUES;

#define rec709_luminosity   srgb_luminosity
#define rec709_saturation   srgb_saturation

#endif // LUMINOSITY_NO_REC709_SUPPORT

/*   Copyright (c) 2016 Simon Otter

     Permission is hereby granted, free of charge, to any person obtaining a
     copy of this software and associated documentation files (the "Software"),
     to deal in the Software without restriction, including without limitation
     the rights to use, copy, modify, merge, publish, distribute, sublicense,
     and/or sell copies of the Software, and to permit persons to whom the
     Software is furnished to do so, subject to the following conditions:
    
     The above copyright notice and this permission notice shall be included in
     all copies or substantial portions of the Software.
    
     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
     IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
     FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
     AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
     LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
     FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
     DEALINGS IN THE SOFTWARE. */