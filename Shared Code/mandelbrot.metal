//
//  mandelbrot.metal
//  Mandelbrot Explorer
//
//  Created by Matusalem Marques on 02/06/2019.
//  Copyright © 2019 Matusalem Marques. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Rect {
    packed_float2 origin;
    packed_float2 size;
};

struct Uniforms {
    Rect visibleRect;
    uint maxIterations;
    float escapeValue;
};

/// Convert a point on the screen to a point in the complex plane.
float2 pixelToComplex(const ushort2 gid, const ushort2 size, const Rect visibleRect) {
    const float scale = max( visibleRect.size.x / size.x, visibleRect.size.y / size.y );
    const float2 offset = (float2(size) * scale - visibleRect.size) / 2.0;
    return float2(gid) * float2x2(scale) + visibleRect.origin - offset;
}

half4 colorForIteration(const float length_squared_z, const uint iteration, const uint maxIterations) {
    float hue = M_PI_F + 4 * M_PI_F * (iteration + 2 - fast::log2( fast::log10( length_squared_z )) ) / maxIterations;
    // Convert to RGB
    return half4((1.0h + fast::cos(hue))/2,
                 (1.0h - fast::cos(hue + M_PI_F/3))/2,
                 (1.0h - fast::cos(hue - M_PI_F/3))/2,
                 1.0h);
}

template<typename T> T complex_square(T c) {
    return T(c.x * c.x - c.y * c.y, 2 * c.x * c.y);
}

kernel void mandelbrot(
                       texture2d<half, access::write> outTexture [[texture(0)]],
                       constant Uniforms &uniforms [[buffer(0)]],
                       const ushort2 gid [[thread_position_in_grid]]
                       ) {
    const ushort2 size = ushort2( outTexture.get_width(), outTexture.get_height() );

    // Return condition for uniform threadgroups
    if (gid.x >= size.x || gid.y >= size.y ) return;

    const float2 c = pixelToComplex(gid, size, uniforms.visibleRect);

    uint i = 0;
    float2 z = 0;
    float length_squared_z;

    do {
        z = complex_square(z) + c;
        length_squared_z = length_squared(z);
    } while (i++ <= uniforms.maxIterations && length_squared_z <= uniforms.escapeValue);

    const half4 color = colorForIteration(length_squared_z, i, uniforms.maxIterations);

    outTexture.write(color, gid);
}
