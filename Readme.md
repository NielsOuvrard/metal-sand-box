# Metal Sand Box

MetalSandBox is a Metal-based application designed as a learning platform for Metal graphics rendering on Apple platforms. This project serves as a practical implementation of concepts from the book ["Metal by Tutorials"](https://www.kodeco.com/books/metal-by-tutorials/v4.0) by Caroline Begbie, Tim Oliver, and Marius Horga.


## Demo's Features

- Render a 3D rocket model, a low-poly house and a 1x1 box
- The scene is rotating on the Y-axis by matrix transformations.
- Toggleable grid display.

## Project Structure

- `ContentView.swift`: The main view of the application, containing the UI elements.
- `MetalView.swift`: A SwiftUI view that integrates with Metal to render graphics.
- `Renderer.swift`: The Metal renderer class that handles rendering points and triangles.
- `Fragment.metal`: The Metal fragment shader that renders the points and triangles.
- `Vertex.metal`: The Metal vertex shader that processes the vertices of the points and triangles.
- And more...

## The Fragment Shader

```metal
fragment float4 fragment_main(
                              constant Params &params [[buffer(ParamsBuffer)]],
                              texture2d<float> baseColorTexture [[texture(BaseColor)]],
                              VertexOut in [[stage_in]])
{
    constexpr sampler textureSampler(filter::linear, address::repeat, mip_filter::linear, max_anisotropy(8));
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv * params.tiling).rgb;
    return float4(baseColor, 1);
}
```

## Screenshots

### Here view from the left of the scene

![Screenshot](Screenshots/preview6.png)

Same view, in wireframe mode, showing the culled triangles, optimized by the Metal API.
![Screenshot](Screenshots/preview8.png)

### Here view from the right of the scene

![Screenshot](Screenshots/preview5.png)
Again, the same view, in wireframe mode, showing the culled triangles, optimized by the Metal API.

![Screenshot](Screenshots/preview7.png)

Screenshot from the iPhone app, an older version

![Screenshot](Screenshots/preview4.jpeg)

We can see the usage of rotation, translation, and scaling in the Metal shaders.
The train is a mesh took from a USDZ file, at the back a square and some points, which the shader is above.
The train is rotated around the center, and the slider controls the rotation.
It is rotated around the bottom-left corner.

![Screenshot](Screenshots/preview3.png)

The train is a mesh took from a USDZ file, at the back a square and some points, which the shader is above.