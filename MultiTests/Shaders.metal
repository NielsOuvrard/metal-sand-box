//
//  shader.metal
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//


#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(0)]];
};

struct VertexInputQuad {
    constant packed_float3 *vertices [[buffer(0)]];
    constant ushort *indices [[buffer(1)]];
    constant float &timer [[buffer(11)]];
};

// vertices are indexed in the vertex buffer.
//vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
//    float4 position = vertex_in.position;
//    position.y -= 1.0;
//    return position;
//}

//vertex float4 vertex_main(constant packed_float3 *vertices [[buffer(0)]], uint vertexID [[vertex_id]])
//{
//    float4 position = float4(vertices[vertexID], 1);
//    return position;
//}

//vertex float4 vertex_main(constant packed_float3 *vertices [[buffer(0)]], constant float &timer [[buffer(11)]], uint vertexID [[vertex_id]])
//{
//    float4 position = float4(vertices[vertexID], 1);
//    position.y += timer;
//    return position;
//}


//vertex float4 vertex_main(constant packed_float3 *vertices [[buffer(0)]], constant ushort *indices [[buffer(1)]], constant float &timer [[buffer(11)]], uint vertexID [[vertex_id]])
//{
//    ushort index = indices[vertexID];
//    float4 position = float4(vertices[index], 1);
//    position.y += timer;
//    return position;
//}

vertex float4 vertex_main(float4 position [[attribute(0)]] [[stage_in]], constant float &timer [[buffer(11)]])
{
    position.y += timer;
    position.x -= cos(timer);
    return position;
}

// vertex float4 vertex_main(VertexInputQuad vertex_in [[stage_in]], uint vertexID [[vertex_id]])
// {
//     ushort index = vertex_in.indices[vertex_in.vertexID];
//     float4 position = float4(vertex_in.vertices[index], 1);
//     return position;
// }

fragment float4 fragment_main() {
    return float4(0, 0, 1, 1);
}
