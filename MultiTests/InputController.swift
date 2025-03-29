//
//  InputController.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 29/03/2025.
//

import GameController

enum GamepadButton: Int {
    case buttonA
    case buttonB
    case buttonX
    case buttonY
    case buttonMenu
    case buttonOptions
    case buttonHome
}

class InputController {
    struct Point {
        var x: Float
        var y: Float
        static let zero = Point(x: 0, y: 0)
    }
    
    static let shared = InputController()
    var keysPressed: Set<GCKeyCode> = []
    var buttonsPressed: Set<GamepadButton> = []
    
    var leftJoystickPosition: CGPoint = .zero
    var rightJoystickPosition: CGPoint = .zero
    
    var leftMouseDown = false
    var mouseDelta = Point.zero
    var mouseScroll = Point.zero
    
    private init() {
        let center = NotificationCenter.default
        
        // keyboard handling
        center.addObserver(
            forName: .GCKeyboardDidConnect,
            object: nil,
            queue: nil) { notification in
                let keyboard = notification.object as? GCKeyboard
                keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
                    if pressed {
                        self.keysPressed.insert(keyCode)
                    } else {
                        self.keysPressed.remove(keyCode)
                    }
                }
            }
        
        // mouse handling
        center.addObserver(
            forName: .GCMouseDidConnect,
            object: nil,
            queue: nil) { notification in
                let mouse = notification.object as? GCMouse
                
                mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                    self.leftMouseDown = pressed
                }
                mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                    self.mouseDelta = Point(x: deltaX, y: deltaY)
                }
                mouse?.mouseInput?.scroll.valueChangedHandler = { _, xValue, yValue in
                    self.mouseScroll.x = xValue
                    self.mouseScroll.y = yValue
                }
            }
        
        // controller handling
        setupControllerListener(center: center)
    }
    
    func setupControllerListener(center: NotificationCenter) {
        center.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            if let controller = GCController.controllers().first {
                self.handleControllerInput(controller: controller)
            }
        }
        
        // Check if a controller is already connected
        if let controller = GCController.controllers().first {
            handleControllerInput(controller: controller)
        }
    }
    
    func handleControllerInput(controller: GCController) {
        guard let gamepad = controller.extendedGamepad else { return }
        
        let buttonMapping: [GamepadButton: GCControllerButtonInput?] = [
            .buttonA: gamepad.buttonA,
            .buttonB: gamepad.buttonB,
            .buttonX: gamepad.buttonX,
            .buttonY: gamepad.buttonY,
            .buttonMenu: gamepad.buttonMenu,
            .buttonOptions: gamepad.buttonOptions,
            .buttonHome: gamepad.buttonHome
        ]
        
        for (buttonType, button) in buttonMapping {
            button?.pressedChangedHandler = { _, _, pressed in
                if pressed {
                    self.buttonsPressed.insert(buttonType)
                    print("Button pressed: \(buttonType)")
                } else {
                    self.buttonsPressed.remove(buttonType)
                    print("Button released: \(buttonType)")
                }
            }
        }
        
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { _, xValue, yValue in
            self.leftJoystickPosition = CGPoint(x: CGFloat(xValue), y: CGFloat(yValue))
        }
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { _, xValue, yValue in
            self.rightJoystickPosition = CGPoint(x: CGFloat(xValue), y: CGFloat(yValue))
        }
    }
}
