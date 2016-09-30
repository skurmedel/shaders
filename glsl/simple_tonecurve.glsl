/*
################################################################################
    NOTE: WHEN USING THESE ROUTINES, IT BEST IF YOU ARE IN LINEAR SPACE.
          USE THE ROUTINES IN gamma_correct.glsl IF YOU NEED.
################################################################################
*/

/*
    This function is the single channel response.

    It is a piecewise function of two degree 3 polynomials.
    
    The first  goes through 0,   0.25 and 0.5.
    The second goes through 0.5, 0.75 and 1.

    The derivative at the midpoint is set to 1.
*/
float simple_tonecurve_ch(in float x, in float l, in float m, in float h)
{    
    if (x < 0.5f)
    {
        return (1 + 16 * l - 8 * m) * x - 2 * (3 + 32 * l - 22 *  m) * x * x 
            +   8 * (1 + 8 * l - 6 * m) * x * x * x; 
    }
    return 2 * (-3 + 8 * h - 6 * m) + (29 - 80 * h + 64 * m) * x 
        +  2 * (-23 + 64 * h - 50 * m) * x * x 
        -  8 * (-3 + 8 * h - 6 * m) * x * x * x;
}

/*
    A simple tonecurve function for values between [0,1] with three control 
    points. The function is pointwise so just apply it to every pixel's colour.
    
    The three control points are at 1/4, 1/2 and 3/4.

    When (low, mid, high) = (1/4, 1/2, 3/4) the response is pretty much a linear
    x function. The function is then in essence pass through (except for float
    -ing point problems) and the image (more or less) visually the same.

    For simple "S-curve" manipulations, it is recommended to keep "mid" at a 
    value of 0.5.

    A light contrast enhancing curve is produced with something like 
        (low, mid, high) = (0.19, 0.5, 0.804)

    This function yields very similar results to Photoshop's curve tool with
    control points at the same places. The exception is when the curve under or
    overshoots, since Photoshop clamps the value.

    If you want almost the same behaviour as PS', just clamp the result between
    vec3(0) and vec3(1). 
*/
vec3 simple_tonecurve_rgb(in vec3 rgb, in float low, in float mid, in float high)
{
    return vec3(
        simple_tonecurve_ch(rgb.r, low, mid, high),
        simple_tonecurve_ch(rgb.g, low, mid, high),
        simple_tonecurve_ch(rgb.b, low, mid, high)
    );
}

/*
    This is the per channel version of simple_tonecurve_rgb. 

    It works the same but each colour channel has an independent control curve.
*/ 
vec3 simple_tonecurve(in vec3 rgb, in vec3 low, in vec3 mid, in vec3 high)
{
     return vec3(
        simple_tonecurve_ch(rgb.r, low.r, mid.r, high.r),
        simple_tonecurve_ch(rgb.g, low.g, mid.g, high.g),
        simple_tonecurve_ch(rgb.b, low.b, mid.b, high.b)
     );
}

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