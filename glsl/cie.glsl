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
highp vec3 Rec709_to_XYZ_D65(highp vec3 RGB)
{
    return mat3(
            0.4124564,  0.3575761,  0.1804375,
            0.2126729,  0.7151522,  0.0721750,
            0.0193339,  0.1191920,  0.9503041
    ) * RGB;
}

/* 
    Convert a XYZ triplet to a linear Rec709 one. 
*/
highp vec3 XYZ_to_Rec709_D65(highp vec3 XYZ)
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
highp vec3 XYZ_to_xyY(highp vec3 XYZ)
{
    return mix(
        vec3(0.3127, 0.3290, 0), // Todo: We assume D65 here!!!
        vec3(
            XYZ.x / (XYZ.x + XYZ.y + XYZ.z),
            XYZ.y / (XYZ.x + XYZ.y + XYZ.z),
            XYZ.y
        ),
        step(0.000001, XYZ.x + XYZ.y + XYZ.z)
    );
}

/*
    Converts a xyY triplet to XYZ.
*/
vec3 xyY_to_XYZ(highp vec3 xyY)
{
    return mix(
        vec3(0, 0, 0),
        vec3(
            (xyY.z / xyY.y) * xyY.x,
            xyY.z,
            (1.0 - xyY.x - xyY.y) * (xyY.z / xyY.y)
        ),
        step(0, xyY.y)
    );
}

const float LAB_f_epsilon  = 0.008856;
const float LAB_f_kappa    = 903.3;

/*
    xyY whitepoint for D65.
*/
const vec2 xyY_D65 = vec2(
    0.31271,
    0.32902
);

/*
    XYZ white point reference for D65 normalized to Y = 1.
*/
const vec3 XnYnZn_D65 = vec3(
    0.950470,
    1.000000,
    0.108883
);

/*
    u' v' coordinates of D65 for CIELUV. 
*/
const vec2 LUV_uv_prim_D65 = vec2(
    (4.0 * XnYnZn_D65.x) / (XnYnZn_D65.x + 15 * XnYnZn_D65.y + 3 * XnYnZn_D65.z),
    (9.0 * XnYnZn_D65.y) / (XnYnZn_D65.x + 15 * XnYnZn_D65.y + 3 * XnYnZn_D65.z)
);

vec2 LUV_uv_prim(vec3 XYZ) 
{
    return vec2(
        (4.0 * XYZ.x) / (XYZ.x + 15.0 * XYZ.y + 3.0 * XYZ.z),
        (9.0 * XYZ.y) / (XYZ.x + 15.0 * XYZ.y + 3.0 * XYZ.z)
    );
}

/*
    Converts from CIE XYZ to CIELUV with illuminant D65.

    The resulting vector has components vec3(L, u, v);
*/
vec3 XYZ_to_LUV_D65(vec3 XYZ)
{    
    float Y_over_Yn = XYZ.y / XnYnZn_D65.y;

    float L = mix(
        LAB_f_kappa * Y_over_Yn,
        116.0 * pow(Y_over_Yn, 1.0/3.0) - 16.0,
        step(LAB_f_epsilon, Y_over_Yn)
    );
    vec2 uv_prim = LUV_uv_prim(XYZ);
    float u = 13.0 * L * (uv_prim.x - LUV_uv_prim_D65.x);
    float v = 13.0 * L * (uv_prim.y - LUV_uv_prim_D65.y);

    return vec3(L, u, v);
}

/*
    Converts a CIELUV triplet to XYZ with illuminant D65.
*/
vec3 LUV_to_XYZ_D65(vec3 LUV)
{
    float L = LUV.x;
    float u = LUV.y;
    float v = LUV.z;

    float Y = mix(
        L / LAB_f_kappa,
        pow((L + 16.0) / 116.0, 3.0),
        step(LAB_f_kappa * LAB_f_epsilon, L)
    );

    float a = (1.0/3.0) * ((52.0 * L) / (u + 13.0 * L * LUV_uv_prim_D65.x) - 1.0);
    float b = -5.0 * Y;
    float c = -1.0/3.0;
    float d = Y * ((39.0 * L) / (v + 13.0 * L * LUV_uv_prim_D65.y) - 5.0);

    float X = (d - b) / (a - c);
    float Z = X * a + b;

    return vec3(X, Y, Z);
}

/*
    Converts from XYZ to LAB with illuminant D65.

    This is a common illuminant for sRGB and Rec709, the other one being D50.
*/
vec3 XYZ_to_LAB_D65(vec3 XYZ)
{  
    #define LAB_f(t) (mix((LAB_f_kappa * t + 16) / 116, pow(t, 1.0/3.0), step(LAB_f_epsilon, t)))

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

    float fy = (L + 16.0) / 116.0;
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
