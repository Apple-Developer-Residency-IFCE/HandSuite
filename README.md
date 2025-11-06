# HandSuite - Apple Developer Residency

HandSuite is a Swift package for **visionOS** that extends RealityKit and ARKit hand tracking.  
It enables developers to create and recognize **custom gestures**, visualize hand data, and build **immersive spatial interactions**.

## Features

- **Full Hand Tracking** – Access both hands, fingers, and joints in real time.  
- **Custom Gesture Recognition** – Define gestures declaratively using direction, curlness, and joint comparisons.  
- **Debugger View** – Visualize hands, fingers, and metrics directly inside an ImmersiveSpace.  
- **Composable Architecture** – Modular design with clear separation between Core, Gestures, and Debugger.  
- **visionOS-First** – Built specifically for Apple Vision Pro using RealityKit + ARKit.

---

## Installation

Add HandSuite to your project via **Swift Package Manager**:

1. In Xcode, go to **File › Add Package Dependencies…**  
2. Paste the repository URL:  
   ```
   https://github.com/Apple-Developer-Residency-IFCE/HandSuite.git
   ```
3. Confirm the version and finish setup.

> **Note:** HandSuite supports **visionOS only**. Running it on another device or the simulator may cause errors.

---

## Usage

### 1. Setup the Immersive View

```swift
import SwiftUI
import HandSuite

struct ImmersiveView: View {
    @State private var isDebugModeEnable = false
    @Environment(HSController.self) var controller: HSController

    var body: some View {
        HSDebuggerRealityView(
            controller: controller,
            isDebugModeEnable: $isDebugModeEnable
        ) { content in
            // Add custom 3D entities if needed
        }
    }
}
```

### 2. Run the Hand Tracking Session

```swift
@Environment(HSController.self) var controller: HSController

.task {
    await controller.requestAuthorization()
    await controller.run()
}
```

### 3. Install and Process a Gesture

```swift
let pinchGesture = PinchGesture()
controller.install(gesture: pinchGesture)

Task {
    while true {
        await MainActor.run {
            controller.processGestures()
            if pinchGesture.wasRecognized {
                print("Pinch detected!")
            }
        }
        try? await Task.sleep(for: .milliseconds(16)) // ~60 FPS
    }
}
```

---

## Core Components

| Component | Description |
|------------|-------------|
| **HSController** | Manages ARKit sessions, hand updates, and gesture processing. |
| **HSHand / HSFinger / HSJoint** | Represent hand anatomy, finger directions, and 3D joint data. |
| **HSGestureScheme** | Protocol for defining and recognizing gestures. |
| **HSDebuggerRealityView** | Visualizes hand data (direction, curlness, positions). |

---

## Example

```swift
let pinch = HSJointComparison(
    firstFinger: .thumb,
    firstJoint: .tip,
    secondFinger: .index,
    secondJoint: .tip,
    constraint: .lessThanOrEqualTo(0.025)
)
```

This represents a **pinch** gesture — when the thumb and index tips are close enough, the gesture triggers.

---

## Documentation

Full documentation at HSDocs.md
Explore the sample **Sandbox** immersive environment for a practical demo.

---

## License
MIT License
Copyright (c) 2025 Apple Developer Residency
