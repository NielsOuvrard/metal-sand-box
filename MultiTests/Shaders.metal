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

vertex VertexOut vertex_main(constant uint &count [[buffer(0)]], constant float &timer [[buffer(11)]], uint vertexID [[vertex_id]])
{
    float radius = 0.8;
    float pi = 3.14159;
    float current = float(vertexID) / float(count);
    float2 position;
    position.x = radius * cos(2 * pi * current + timer);
    position.y = radius * sin(2 * pi * current + timer);
    VertexOut out {
        .position = float4(position, 0, 1),
        .color = float4(1, 0, 0, 1),
        .pointSize = 20
    };
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]]) {
    return in.color;
}
