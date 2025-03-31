//
//  GameScene.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 29/03/2025.
//

import MetalKit

struct GameScene {
    // lazy = initialized only when it's first used
    lazy var house: Model = {
        let house = Model(name: "lowpoly-house.usdz")
        house.setTexture(name: "barn-color", type: BaseColor)
        return house
    }()
    
    lazy var ground: Model = {
        let ground = Model(name: "ground", primitiveType: .plane)
        ground.setTexture(name: "grass", type: BaseColor)
        ground.tiling = 16
        ground.transform.scale = 40
        ground.transform.rotation.z = Float(90).degreesToRadians
        
        ground.transform.rotation.x = Float(180).degreesToRadians
        return ground
    }()
    
    lazy var box: Model = {
        var box = Model(name: "box", primitiveType: .box)
        box.position.x = 2.8
        box.position.y = 1
        box.position.z = 0
        box.setTexture(name: "steel", type: BaseColor)
        return box
    }()
    
    lazy var rocket: Model = {
        var rocket = Model(name: "rocket.usdz")
        
        rocket.position.x = -3
        rocket.position.y = 0.5
        rocket.rotation.z = -0.6
        // rocket.rotation.x = cos(timer)
        rocket.scale = 0.1
        return rocket
    }()

    lazy var models: [Model] = [ground, house, box, rocket]
    var camera = PlayerCamera()
    let lighting = SceneLighting()    
    
    init() {
        camera.position = [0, 1.4, -4.0]
    }
    
    mutating func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
    }
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
}
