/*
    Contains very cheap and dirty bloom screen effects. 

    Bloom originally refers to halo effects around highlights on film.

    If FAST_BLOOM_LUMA_FUNCTION is not defined, luma.glsl is a dependency for 
    this file.

    As is often the case, the effect is best done in linear space.
*/

/*
    A function used to sample a texture. By default it is just bound to 
    texture(tex, pos, bias).

    You can override it with another function with a similar signature, for 
    example if you need to gamma correct the input or something similar.
*/
#ifndef FAST_BLOOM_SAMPLE_TEXTURE
#define FAST_BLOOM_SAMPLE_TEXTURE(tex, pos, bias)    texture(tex, pos, bias)
#endif

#ifndef FAST_BLOOM_LUMA_FUNCTION
// We use luma.glsl here if the user doesn't provide their own.
#include "luma.glsl"
#define FAST_BLOOM_LUMA_FUNCTION(rgb)                srgb_luma(rgb)
#endif  

/*
    A fast way to get some kind of bloom effect using just 1 texture call. It 
    uses the mip maps to fake blur.

    tex should be mipmapped at least bilinear (preferrably trilinear+). Bilinear
    looks odd if you animate the scale.
    
    pos is the pixel position.

    threshold controls the cutoff for the bloom, low values look bad. If the 
    input is HDR then values above the "displayable range" and above look best.

    scale controls what mipmap and how strong the effect is.

    Returns just the bloom component. Add it to your original pixel sample to
    complete the effect.
*/
vec3 fast_bloom(
    in sampler2D    tex,
    in vec2         pos,
    in float        threshold,
    in float        scale
)
{
    vec3 rgb = (FAST_BLOOM_SAMPLE_TEXTURE(tex, pos, scale)).rgb;
    float luma = FAST_BLOOM_LUMA_FUNCTION(rgb);

    return mix(vec3(0), vec3(1), step(threshold, luma) * scale * (luma -threshold));
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