/*
    CIE related operations.

    Tries to provide:

        - Operations to and from XYZ and common spaces.
        - CIE xyY transform
        - CIE LAB support

    Tries to support the following spaces:

        - "sRGB"        IEC 61966-2-1:1999     
        - "Rec.709"     ITU-R Recommendation BT.709
    
    This file has the following naming conventions:

        Anything related to a space is named SPACE_operation
            Transforms are named SPACE1_to_SPACE2
            If an illuminant is assumed, like D65:
                 SPACE1_to_SPACE2_D65
    
    The spaces have the following names:

        - XYZ           CIE XYZ
        - xyY           CIE xy chromaticity coordinates, with z as Y.
        - LAB           CIE LAB
        - sRGB          (see above)
        - Rec709        (see above)

    Most of the operations assume the input space are in linear space, you can
    use the functions from gamma_correct.glsl to remove the gamma correction.
*/

/*
    Convert a Rec709 linear triplet to a XYZ one.
*/ 
vec3 Rec709_to_XYZ(vec3 RGB)
{
    return mat3(
            0.412453,   0.357580,   0.180423,
            0.212671,   0.715160,   0.072169,
            0.019334,   0.119193,   0.950227
    ) * RGB;
}

/* 
    Convert a XYZ triplet to a linear Rec709 one. 
*/
vec3 XYZ_to_Rec709(vec3 XYZ)
{
    return mat3(
            3.240479,   -1.537150,  -0.498535,
            -0.969256,  1.875992,   0.041556,
            0.055648,   -0.204043,  1.057311
    ) * XYZ;
}

/*
    Converts a XYZ triplet to a xyY (CIE chromaticity coordinates).
*/
vec3 XYZ_to_xyY(vec3 XYZ)
{
    return vec3(
        XYZ.x / (XYZ.x + XYZ.y + XYZ.z),
        XYZ.y / (XYZ.x + XYZ.y + XYZ.z),
        XYZ.y
    );
}

/*
    Converts a xyY triplet to XYZ.
*/
vec3 xyY_to_XYZ(vec3 xyY)
{
    float X = (xyY.x / xyY.y) * xyY.z;
    float Y = xyY.z;
    float Z = ((1.0 - xyY.x - xyY.y) / xyY.y) * xyY.z;
    return vec3(X, Y, Z);    
}

const float LAB_f_epsilon  = 0.008856;
const float LAB_f_kappa    = 903.3;

/*
    XYZ white point reference for D65, with Y = 100 as normalization.
*/
const vec3 XnYnZn_D65 = vec3(
    95.047,
    100,
    108.883
);   

vec3 LAB_RGB_compand(vec3 RGB)
{
    vec3 
}

/*
    Converts from XYZ to LAB with illuminant D65.

    This is the same illuminant as the one used by sRGB and Rec709.
*/
vec3 XYZ_to_LAB_D65(vec3 XYZ)
{  
    #define LAB_f(t) (mix(pow(t, 1.0/3.0), (LAB_f_kappa * t + 16) / 116, step(LAB_f_epsilon, t)))

    float f_y = LAB_f(XYZ.y/XnYnZn_D65.y);

    vec3 LAB = vec3(
        116.0 * f_y - 16.0,
        500.0 * (LAB_f(XYZ.x/XnYnZn_D65.x) - f_y),
        200.0 * (f_y - LAB_f(XYZ.z/XnYnZn_D65.z))
    );

    return LAB;
    #undef LAB_f
}

/*
    Converts from LAB to XYZ with illuminant D65.
*/
vec3 LAB_to_XYZ_D65(vec3 LAB)
{
    float L = LAB.x; float a = LAB.y; float b = LAB.z;

    float fy = (L + 16) / 116.0;
    float fx = a / 500.0 + fy;
    float fz = fy - b / 200.0;

    vec3 f3 = pow(vec3(fx, fy, fz), vec3(3));

    float xr = f3.x * step(LAB_f_epsilon, f3.x) 
             + ((116 * fx - 16) / LAB_f_kappa) * (1 - step(LAB_f_epsilon, f3.x));
    float yr = f3.y * step(LAB_f_epsilon * LAB_f_kappa, L) 
             + (L / LAB_f_kappa) * (1 - step(LAB_f_epsilon * LAB_f_kappa, L));
    float zr = f3.z * step(LAB_f_epsilon, f3.z) 
             + ((116 * fz - 16) / LAB_f_kappa) * (1 - step(LAB_f_epsilon, f3.x));
    
    return vec3(
        XnYnZn_D65.x * xr,
        XnYnZn_D65.y * yr,
        XnYnZn_D65.z * zr
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
