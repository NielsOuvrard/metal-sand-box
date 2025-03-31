//
//  Vertex.metal
//  MultiTests
//
//  Created by Niels Ouvrard on 24/03/2025.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"
#import "ShaderDefs.h"

vertex VertexOut vertex_main(
                             VertexIn in [[stage_in]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    float4 position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * in.position;
    float4 worldPosition = uniforms.modelMatrix * in.position;
    VertexOut out {
        .position = position,
        .normal = in.normal,
        .uv = in.uv,
        .worldPosition = worldPosition.xyz / worldPosition.w,
        .worldNormal = uniforms.normalMatrix * in.normal
    };
    return out;
}
