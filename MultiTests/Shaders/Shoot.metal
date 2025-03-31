//
//  Shoot.metal
//  MultiTests
//
//  Created by Niels Ouvrard on 31/03/2025.
//

#include <metal_stdlib>
using namespace metal;

#include "Common.h"

struct VertexOut {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex VertexOut vertex_primitives(
                              constant float3 *vertices [[buffer(0)]],
                              constant Uniforms &uniforms [[buffer(UniformsBuffer)]],
                              uint id [[vertex_id]])
{
    matrix_float4x4 mvp = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix;
    VertexOut out {
        .position = mvp * float4(vertices[id], 1),
        .point_size = 25.0
    };
    return out;
}

fragment float4 fragment_primitives_point(
                                     float2 point [[point_coord]],
                                     constant float3 &color [[buffer(1)]])
{
    float d = distance(point, float2(0.5, 0.5));
    if (d > 0.5) {
        discard_fragment();
    }
    return float4(color, 1);
}

fragment float4 fragment_primitives_line(
                                    constant float3 &color [[buffer(1)]])
{
    return float4(color ,1);
}
