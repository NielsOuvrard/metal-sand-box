//
//  SceneLightning.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 30/03/2025.
//

struct SceneLighting {
    static func buildDefaultLight() -> Light {
        var light = Light()
        light.position = [0, 0, 0]
        light.color = [1, 1, 1]
        light.specularColor = [0.6, 0.6, 0.6]
        light.attenuation = [1, 0, 0]
        light.type = Sun
        return light
    }
    
    let sunlight: Light = {
        var light = Self.buildDefaultLight()
        light.position = [1, 2, -2]
        return light
    }()
    
    let ambientLight: Light = {
        var light = Self.buildDefaultLight()
        light.color = [0.04, 0.04, 0.04]
        light.type = Ambient
        return light
    }()
    
    let redLight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Point
        light.position = [-2, 0.76, -0.18]
        light.color = [1, 0, 0]
        light.attenuation = [0.5, 2, 1]
        return light
    }()
    
    lazy var spotlight: Light = {
        var light = Self.buildDefaultLight()
        light.type = Spot
        light.position = [0, 0.64, 3.07]
        light.color = [0, 0, 1]
        light.attenuation = [1, 0, 0]
        light.coneAngle = Float(20).degreesToRadians
        light.coneDirection = [0, -0.15, -0.5]
        light.coneAttenuation = 32
        return light
    }()
    
    var lights: [Light] = []
    
    init() {
        lights.append(sunlight)
        lights.append(ambientLight)
        lights.append(redLight)
        lights.append(spotlight)
    }
}
