//
//  ContentView.swift
//  MultiTests
//
//  Created by Niels Ouvrard on 02/02/2025.
//

import MetalKit
import ModelIO
import SwiftUI
import GameController

let originalColor = Color(red: 0.8, green: 0.8, blue: 0.8)
let size: CGFloat = 400

struct CubeModifier: Equatable {
    var rotateX: Bool = true
    var rotateY: Bool = true
    var rotateZ: Bool = true
    var angleX: Float = 0
    var angleY: Float = 0
    var angleZ: Float = 0
}

struct ContentView: View {
    @State private var showGrid = true
    @State private var totalPoints: UInt32 = 50
    @State private var selectedColor = Color.red
    @State private var modifier: CubeModifier = .init()
    
    @State private var leftJoystickPosition: CGPoint = .zero
    @State private var rightJoystickPosition: CGPoint = .zero
    @State private var isAButtonPressed = false

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MetalView(totalPoints: $totalPoints,
                          rightJoystickPosition: $rightJoystickPosition,
                          leftJoystickPosition: $leftJoystickPosition,
                          modifier: $modifier,
                          color: $selectedColor)
                    .border(Color.black, width: 2)
                if showGrid {
                    Grid()
                }
            }
            .frame(height: size)
            .padding()


            ScrollView {
                Toggle("Show Grid", isOn: $showGrid)
                
                Text("Total Points: \(totalPoints)")
                Slider(value: Binding(
                    get: { Double(totalPoints) },
                    set: { totalPoints = UInt32($0) }
                ), in: 1...100, step: 1)
                
                Text("AngleX: \(modifier.angleX)")
                Toggle("Rotate X", isOn: $modifier.rotateX)
                Slider(value: Binding(
                    get: { Double(modifier.angleX) },
                    set: { modifier.angleX = Float($0) }
                ), in: -180...180, step: 1)
                
                Text("AngleY: \(modifier.angleY)")
                Toggle("Rotate Y", isOn: $modifier.rotateY)
                Slider(value: Binding(
                    get: { Double(modifier.angleY) },
                    set: { modifier.angleY = Float($0) }
                ), in: -180...180, step: 1)
                
                Text("AngleZ: \(modifier.angleZ)")
                Toggle("Rotate Z", isOn: $modifier.rotateZ)
                Slider(value: Binding(
                    get: { Double(modifier.angleZ) },
                    set: { modifier.angleZ = Float($0) }
                ), in: -180...180, step: 1)
                
                ColorPicker("Square Color", selection: $selectedColor)
                
            }
        }
        .onAppear {
            setupControllerListener()
        }
    }

    func setupControllerListener() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            if let controller = GCController.controllers().first {
                handleControllerInput(controller: controller)
            }
        }

        // Check if a controller is already connected
        if let controller = GCController.controllers().first {
            handleControllerInput(controller: controller)
        }
    }

    func handleControllerInput(controller: GCController) {
        
        controller.extendedGamepad?.buttonA.pressedChangedHandler = { _, _, pressed in
            isAButtonPressed = pressed
            print("Pressed A")
        }

        // Handle left thumbstick (directional joystick)
        controller.extendedGamepad?.leftThumbstick.valueChangedHandler = { _, xValue, yValue in
            leftJoystickPosition = CGPoint(x: CGFloat(xValue), y: CGFloat(yValue))
            print("Left Thumbstick - X: \(xValue), Y: \(yValue)")
            // Use xValue and yValue to update your state or perform actions
        }
        // Handle left thumbstick (directional joystick)
        controller.extendedGamepad?.rightThumbstick.valueChangedHandler = { _, xValue, yValue in
            rightJoystickPosition = CGPoint(x: CGFloat(xValue), y: CGFloat(yValue))
            print("Left Thumbstick - X: \(xValue), Y: \(yValue)")
            // Use xValue and yValue to update your state or perform actions
        }
    }
}

struct Key: View {
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Rectangle()
                    .foregroundColor(originalColor)
                    .frame(width: 20, height: 20)
                Text("Original triangle")
            }
            HStack {
                Rectangle()
                    .foregroundColor(.red)
                    .frame(width: 20, height: 20)
                Text("Transformed triangle")
            }
        }
        .padding(0)
    }
}

struct Grid: View {
    var cellSize: CGFloat = size / 20
    var body: some View {
        ZStack {
            HStack {
                ForEach(0..<Int(cellSize), id: \.self) { _ in
                    Spacer()
                    Divider()
                }
            }
            VStack {
                ForEach(0..<Int(cellSize), id: \.self) { _ in
                    Spacer()
                    Divider()
                }
            }
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
            Rectangle()
                .frame(width: 1)
                .frame(maxHeight: .infinity)
        }
    }
}

#Preview {
    ContentView()
}


// You do have the option not to use a vertex
// descriptor and just send an array of vertices in an MTLBuffer
