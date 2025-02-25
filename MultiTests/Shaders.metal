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

// vertices are indexed in the vertex buffer.
vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
    float4 position = vertex_in.position;
    //position.y -= 1.0;
    return position;

}

fragment float4 fragment_main() {
    return float4(0, 0, 1, 1);
}
