//
//  Fragment.metal
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"
#import "ShaderDefs.h"

fragment float4 fragment_main(
                              constant Params &params [[buffer(ParamsBuffer)]],
                              constant Light *lights [[buffer(LightBuffer)]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              VertexOut in [[stage_in]])
{
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear, max_anisotropy(8));
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    float3 normalDirection = normalize(in.worldNormal);
    float3 color = phongLighting(normalDirection, in.worldPosition, params, lights, baseColor);
    return float4(color, 1);
}
