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

vertex VertexOut triangle_vertex_main(VertexIn in [[stage_in]], constant float &timer [[buffer(11)]])
{
    VertexOut out {
        .position = in.position,
        .color = in.color
        // .pointSize = 200
    };
    return out;
}

// vertex function’s fundamental task is positioning vertices
vertex VertexOut point_vertex_main(constant uint &count [[buffer(12)]], constant float &timer [[buffer(11)]], uint vertexID [[vertex_id]])
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
