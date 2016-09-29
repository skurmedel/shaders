/*
    Gamma correction routines ("transfer functions").

    The following standards are supported:

        - "sRGB"        IEC 61966-2-1:1999     
                        Most computer screens use this transfer function. If you
                        are making a PC game, you want these. 
    
        - "Rec.709"     ITU-R Recommendation BT.709
                        HDTV's, etc.
    
        - "Rec.2020"    ITU-R Recommendation BT.2020
                        4K, 8K, UHDT. This function is very similar to Rec.709
                        but we support additional control for 10 and 12 bit 
                        systems as recommended by the standard (overkill? yes.)

    Rec.709's transfer function seems pretty much identical to Rec.601 so the 
    older standard has no corresponding functions.
    
    Most implementations take the form of a *linearize function and a 
    *gamma_correct function. The first one takes gamma correct input, 
    and transforms it into a linear space.

    The second one takes linear space input and gamma corrects it.

    They are obviously each other's inverse.

    Care has been taken so that the standard functions all have the same 
    signature, so you can use a macro or define and swap 'em out for different
    targets.

    For neat freaks the following defines can be used to remove functionality 
    not desired in the final compilation (although the compiler probably will
    optimise it away anyhow):
        GAMMA_CORRECT_NO_SRGB_SUPPORT
        GAMMA_CORRECT_NO_REC709_SUPPORT
        GAMMA_CORRECT_NO_REC2020_SUPPORT
    There's also GAMMA_CORRECT_ONLY_SRGB_SUPPORT that is effectively ifdefing 
    out all the other standards.
*/

#ifndef GAMMA_CORRECT_NO_SRGB_SUPPORT
/*
    Takes an sRGB gamma corrected triple and linearizes it.

    The input is assumed to be gamma corrected with 2.2.

    The sRGB gamma function is not just pow(x, 2.2), but instead a function that
    is linear close to black and non-linear for brighter colours.
*/
vec3 srgb_gamma_linearize(in vec3 rgb)
{
    // Defined by the sRGB standard, as are all the other constants.
    const float a = 0.055f;

    // We use step here to avoid an if clause since those are generally not 
    // recommended in a GPU context.
#define SRGB_TRANSFORM_CH(v, x) {\
    float selector = step(0.04045, x);\
    v = (1 - selector) * (x / 12.95f)\
      + (    selector) * pow((x + a)/(1 + a), 2.4);}

    vec3 ret = vec3(0);
    SRGB_TRANSFORM_CH(ret.r, rgb.r);
    SRGB_TRANSFORM_CH(ret.g, rgb.g);
    SRGB_TRANSFORM_CH(ret.b, rgb.b);

#undef SRGB_TRANSFORM_CH

    return ret;
}

/*
    Takes a linear colour triple and gamma corrects it according to sRGB 
    standards.

    See the comments for srgb_gamma_linearize for more info.
*/ 
vec3 srgb_gamma_correct(in vec3 rgb)
{
    const float a = 0.055f;

#define SRGB_TRANSFORM_CH(v, x) {\
    float selector = step(0.0031308, x);\
    v = (1 - selector) * (x * 12.95f)\
      + (    selector) * ((1 + a) * pow(x, 1.0f/2.4f) - a);}

    vec3 ret = vec3(0);
    SRGB_TRANSFORM_CH(ret.r, rgb.r);
    SRGB_TRANSFORM_CH(ret.g, rgb.g);
    SRGB_TRANSFORM_CH(ret.b, rgb.b);

#undef SRGB_TRANSFORM_CH

    return ret;
}
#endif

#ifndef GAMMA_CORRECT_ONLY_SRGB_SUPPORT
#ifndef GAMMA_CORRECT_NO_REC709_SUPPORT
/*
    Takes an Rec.709 gamma correct value and linearizes it.

    Like the sRGB standard the gamma function isn't a straight power function,
    it uses two parts, one linear close to black. It is pretty similar to the 
    one in sRGB but not on a negligeable level.
*/
vec3 rec709_linearize(in vec3 rgb)
{
    /*
        Technically, the x / 4.5 should only happen if x is LESS THAN, but now 
        it's LESS THAN OR EQUAL... which isn't 100% true to the standard.
    */ 
    #define REC709_TRANSFORM_CH(v, x) {\
        float selector = step(0.081, x);
        v = (1 - selector) * (x / 4.5)\
          + (    selector) * pow((v + 0.099) / 1.099, 1.0/0.45); }

    vec3 ret = vec3(0);
    REC709_TRANSFORM_CH(ret.r, rgb.r);
    REC709_TRANSFORM_CH(ret.g, rgb.g);
    REC709_TRANSFORM_CH(ret.b, rgb.b);

    #undef REC709_TRANSFORM_CH

    return ret;
}

/*
    Takes a linear colour triplet and gamma corrects it according to Rec.709.

    See rec709_linearize for more info. 
*/
vec3 rec709_gamma_correct(in vec3 rgb)
{
    /*
        Technically, the first part should only happen if x is LESS THAN, but 
        now it's LESS THAN OR EQUAL... which isn't 100% true to the standard.
    */ 
    #define REC709_TRANSFORM_CH(v, x) {\
        float selector = step(0.018, x);
        v = (1 - selector) * (4.5 * x)\
          + (    selector) * (1.099 * pow(x, 0.45) - 0.099); }

    vec3 ret = vec3(0);
    REC709_TRANSFORM_CH(ret.r, rgb.r);
    REC709_TRANSFORM_CH(ret.g, rgb.g);
    REC709_TRANSFORM_CH(ret.b, rgb.b);

    #undef REC709_TRANSFORM_CH

    return ret;
}
#endif // ifndef GAMMA_CORRECT_NO_REC709_SUPPORT

#endif // ifndef GAMMA_CORRECT_ONLY_SRGB_SUPPORT

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