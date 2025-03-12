//
//  shader.metal
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//


#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float pointSize [[point_size]];
    float4 color;
};

struct VertexIn {
    float4 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

vertex VertexOut vertex_main(VertexIn in [[stage_in]], constant float &timer [[buffer(11)]])
{
    VertexOut out {
        .position = in.position,
        .color = in.color,
        .pointSize = 200
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
