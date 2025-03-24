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

struct ContentView: View {
    @State private var showGrid = false
    @State private var vertexCullingOn = true
    @State private var wierframeOn = false
    @State private var sceneMoving = true
    @State private var selectedColor = Color.red
    
    @State private var leftJoystickPosition: CGPoint = .zero
    @State private var rightJoystickPosition: CGPoint = .zero
    @State private var isAButtonPressed = false

    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MetalView(rightJoystickPosition: $rightJoystickPosition,
                          leftJoystickPosition: $leftJoystickPosition,
                          vertexCullingOn: $vertexCullingOn,
                          wierframeOn: $wierframeOn,
                          sceneMoving: $sceneMoving,
                          color: $selectedColor)
                    .border(Color.black, width: 2)
                if showGrid {
                    Grid()
                }
            }
            .frame(height: size)
            .padding()


            ScrollView {
                Toggle("Grid", isOn: $showGrid)
                Toggle("Vertex Culling", isOn: $vertexCullingOn)
                Toggle("Wierframe", isOn: $wierframeOn)
                Toggle("Pause", isOn: $sceneMoving)
                
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
