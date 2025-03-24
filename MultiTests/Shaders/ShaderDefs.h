//
//  ShaderDefs.h
//  MultiTests
//
//  Created by Niels Ouvrard on 24/03/2025.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 uv [[attribute(UV)]];
};

struct VertexOut {
    float4 position [[position]];
    float3 normal;
    float2 uv;
};
