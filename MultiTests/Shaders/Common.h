//
//  Common.h
//  MultiTests
//
//  Created by Niels Ouvrard on 17/03/2025.
//


#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    unsigned int width;
    unsigned int height;
    unsigned int tiling;
} Params;

typedef enum {
    VertexBuffer = 0,
    UVBuffer = 1,
    UniformsBuffer = 11,
    ParamsBuffer = 12
} BufferIndices;

typedef enum {
    Position = 0,
    Normal = 1,
    UV = 2
} Attributes;

typedef enum {
    BaseColor = 0
} TextureIndices;

#endif /* Common_h */
