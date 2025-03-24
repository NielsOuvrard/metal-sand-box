//
//  Fragment.metal
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

#include <metal_stdlib>
using namespace metal;
#import "Common.h"
#import "ShaderDefs.h"

fragment float4 fragment_main(
                              constant Params &params [[buffer(ParamsBuffer)]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              VertexOut in [[stage_in]])
{
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear, max_anisotropy(8));
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    return float4(baseColor, 1);
}
