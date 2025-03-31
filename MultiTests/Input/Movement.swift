//
//  Movement.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 29/03/2025.
//


enum Settings {
    static var rotationSpeed: Float { 2.0 }
    static var translationSpeed: Float { 3.0 }
    static var mouseScrollSensitivity: Float { 0.1 }
    static var mousePanSensitivity: Float { 0.008 }
}

protocol Movement where Self: Transformable {
}

extension Movement {
    var forwardVector: float3 {
        normalize([sin(rotation.y), 0, cos(rotation.y)])
    }
    var rightVector: float3 {
        [forwardVector.z, forwardVector.y, -forwardVector.x]
    }
    
    func updateInput(deltaTime: Float) -> Transform {
        var transform = Transform()
        let rotationAmount = deltaTime * Settings.rotationSpeed
        let translationAmount = deltaTime * Settings.translationSpeed
        let input = InputController.shared
        var direction: float3 = .zero
        
        // * mouse
        if input.keysPressed.contains(.keyW) {
            direction.z += 1
        }
        if input.keysPressed.contains(.keyS) {
            direction.z -= 1
        }
        if input.keysPressed.contains(.keyA) {
            direction.x -= 1
        }
        if input.keysPressed.contains(.keyD) {
            direction.x += 1
        }
        if direction != .zero {
            direction = normalize(direction)
        }
        
        // * controller
        transform.rotation.y += Float(input.rightJoystickPosition.x) * rotationAmount
        transform.rotation.x += Float(input.rightJoystickPosition.y) * rotationAmount
        
        if input.leftJoystickPosition != .zero {
            direction.z = Float(input.leftJoystickPosition.y)
            direction.x = Float(input.leftJoystickPosition.x)
            
            // Clamp the magnitude of the direction vector to 1
            let magnitude = sqrt(direction.x * direction.x + direction.z * direction.z)
            if magnitude > 1 {
                direction /= magnitude // Scale the vector to have a magnitude of 1
            }
        }
        
        // Move
        if direction != .zero {
            transform.position += (direction.z * forwardVector + direction.x * rightVector) * translationAmount
        }
        return transform
    }
}
