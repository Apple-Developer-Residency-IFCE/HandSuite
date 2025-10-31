# HandSuite - Apple Developer Residency

HandSuite is a Swift package for **visionOS (Apple Vision Pro)** that allows developers to manipulate hand-tracking data provided by **RealityKit** and **ARKit**.  
It expands Vision Pro’s gesture system, enabling the creation of **custom gestures** to interact and build immersive spatial experiences.

## How to Install

HandSuite currently supports installation only via **Swift Package Manager (SPM)**.

To install it:

    1. Open your project in Xcode.  
    2. Go to File › Add Package Dependencies…  
    3. Paste the GitHub repository URL.  
    4. Confirm the version and finish.

It’s the same process used for other packages like **SwiftLint**.

> **Note:** HandSuite is designed exclusively for **visionOS**.  
> Running it on other devices or in the **Xcode Simulator** may cause errors or unexpected behavior.

## Documentation (In Progress)

This section explains all core files, objects, enums, and structs available in the package.  
The documentation is still under active development.


### Sandbox

The **Sandbox** is a sample immersive environment demonstrating HandSuite’s usage.  
The package must always be used within an **ImmersiveSpace**.

#### ImmersiveView

The key view in the Sandbox is `HSDebuggerRealityView`, which displays what Vision Pro “sees” — including **hand direction**, **curlness**, and **finger positions**.

```swift
struct ImmersiveView: View {
    @State private var isDebugModeEnable = false
    @Environment(HSController.self) var controller: HSController

    var body: some View {
        HSDebuggerRealityView(
            controller: controller,
            isDebugModeEnable: $isDebugModeEnable
        ) { content in
            // Use content.add(_) if needed
        }
    }
}

```

## Debugger
The Debugger folder are the files thar allows the developer to create a panel with all information from Hands and Fingers the HandSuite outputs.

The main component of the Debugger is the `HSDebuggerRealityView`, it allows the developer to see informations, such as: Direction, Curlness and Position of, both, Hands and Fingers, in a visual way. That visualization in important to facilitate the understanting the metrics that will be used in the creation of Gestures.

```
HSDebuggerRealityView (controller: HSController, isDebugModeEnable: bool)
```

The HSDebuggerRealityView receives the `HSController` responsible for handling the information listed above, to the user by the `HSDebuggerRealityView. The `isDebugModeEnable` allows the user to enable or disable the DebugPanel.

## Core
The Core folder contains the fundamental classes of HandSuite:
- HSHand
- HSFinger
- HSJoint
- HSController

### HSHand
The HSHand class represents a human hand, provinding access to `Fingers`, `Joints` and `Direction` in 3D space.
#### Responsabilities:
- Stores the hand’s chirality (.left or .right).
- Initializes and manages all fingers (HSFinger) and their joints (HSJoint).
- Calculates the palm direction (HSDirection).
- Optionally adds 3D debug entities (like spheres) to visualize each joint.
#### Inicialization:
```
let leftHand = HSHand (chirality = .left)
let rightHand = HSHand (chirality = .right)
```
#### Key Methods

- `addToContent(_:)`
Adds each hand joint as a small 3D sphere to your RealityKit content for visualization.
```
RealityView { content in
    leftHand.addToContet(content)
}
```

- `getFinger(name: HSFinger.Name) -> HSFinger`
Returns a finger instance for inspection or custom gesture definition.
```
RealityView { content in
    leftHand.getFinger(name: .thumb)
}
```

- `getPalmDirection() -> HSDirection`
Calculates the direction the palm is facing, based on the `HSDirection` enum.
```
let direction = leftHand.getPalmDirection()

switch direction {
case .up: print("Palm facing up")
case .down: print("Palm facing down")
case .front: print("Palm facing forward")
case .back: print("Palm facing backward")
}
```
### HSFinger
The `HSFinger` class represents an individual finger within a tracked hand.  
It contains detailed data about the finger’s `Direction`, `State`, `Curlness`, and its `Joints` (e.g., tip, knuckle).  
Each `HSFinger` belongs to a specific `HSHand`, allowing full-hand tracking and gesture analysis.
#### Responsabilities:
- Holds all joints associated with a single finger (`HSJoint`)
- Computes `Direction` (which way the finger is pointing)
- Computes `Curlness` (how much the finger is bent)
- Maintains the **state** (`.curl` or `.straight`)
- Updates 3D joint transforms from ARKit’s `HandAnchor`

#### Inicialization:
```
let finger = HSFinger(name: HSFinger.Name, hand: HSHand)
```
#### Key Methods

 - `getCurlAmount()
Asynchronously calculates how bent the finger is by comparing the angles between sequential joints.
```
if let directionVector = indexFinger.calculateFingerDirection() {
    print("Finger direction vector:", directionVector)
}
```
#### Example usage
```
// Inside a Hand Update Cycle
Task {
    if let anchor = controller.latestHandTracking.rightAnchor {
        let indexFinger = controller.rightHand.getFinger(named: .index)
        await indexFinger.update(using: anchor)

        print("Direction:", indexFinger.direction)
        print("Curlness:", indexFinger.curlness)
        print("State:", indexFinger.state)
    }
}

```

## Gestures
Documentation on Progress;

## Utils
Documentation on Progress;
