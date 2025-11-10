# HandSuite - Apple Developer Residency

HandSuite is a Swift package for visionOS (Apple Vision Pro) that allows developers to manipulate hand-tracking data provided by RealityKit and ARKit.  
It expands Vision Pro’s gesture system, enabling the creation of custom gestures to interact and build immersive spatial experiences.

## How to Install

HandSuite currently supports installation only via Swift Package Manager (SPM).

To install it:

    1. Open your project in Xcode.  
    2. Go to File › Add Package Dependencies…  
    3. Paste the GitHub repository URL.  
    4. Confirm the version and finish.

It’s the same process used for other packages like **SwiftLint**.

> Note: HandSuite is designed exclusively for visionOS.  
> Running it on other devices or in the Xcode Simulator may cause errors or unexpected behavior.

## Documentation (In Progress)

This section explains all core files, objects, enums, and structs available in the package.  
The documentation is still under active development.


### Sandbox

The Sandbox is a sample immersive environment demonstrating HandSuite’s usage.  
The package must always be used within an ImmersiveSpace.

#### ImmersiveView

The key view in the Sandbox is `HSDebuggerRealityView`, which displays what Vision Pro “sees” — including hand direction, curlness, and finger positions.

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
```swift
RealityView { content in
    leftHand.addToContet(content)
}
```

- `getFinger(name: HSFinger.Name) -> HSFinger`
Returns a finger instance for inspection or custom gesture definition.
```swift
RealityView { content in
    leftHand.getFinger(name: .thumb)
}
```

- `getPalmDirection() -> HSDirection`
Calculates the direction the palm is facing, based on the `HSDirection` enum.
```swift
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
```swift
let finger = HSFinger(name: HSFinger.Name, hand: HSHand)
```
#### Key Methods
 - `getCurlAmount()
Asynchronously calculates how bent the finger is by comparing the angles between sequential joints.
```swift
if let directionVector = indexFinger.calculateFingerDirection() {
    print("Finger direction vector:", directionVector)
}
```
#### Example usage
```swift
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
### HSJoint
The `HSJoint` class represents the anatomics subdivisions of each finger individually (e.g. metacarpal). 
#### Responsabilities:
- Return the 3D models for the Hand visualization.
- Allow distance comparison.

#### Inicialization:
```swift
let tipJoint = HSJoint(name: .tip, finger: indexFinger)
```
#### Key Methods

 - update3DAsset()
Assigns a custom 3D model (e.g., a small sphere) to represent this joint in RealityKit.
```swift
let sphere = ModelEntity(mesh: .generateSphere(radius: 0.005))
tipJoint.update3DAsset(sphere)
```
#### Example usage
```swift
let indexFinger = HSFinger(name: .index, hand: leftHand)
if let tip = indexFinger.joints[.tip] {
    let sphere = ModelEntity(mesh: .generateSphere(radius: 0.005))
    tip.update3DAsset(sphere)
}
```
#### HSJointComparison
The HSJointComparison struct is used to compare two joints — typically from two different fingers — based on a distance constraint.
This enables simple, declarative gesture definitions (e.g., detecting a pinch between the thumb and index tip).
#### Inicialization:
```swift
let pinchComparison = HSJointComparison(
    firstFinger: .thumb,
    firstJoint: .tip,
    secondFinger: .index,
    secondJoint: .tip,
    constraint: .lessThanOrEqualTo(0.02)
)
```
#### Example usage
```swift
let thumbToIndex = HSJointComparison(
    firstFinger: .thumb,
    firstJoint: .tip,
    secondFinger: .index,
    secondJoint: .tip,
    constraint: .lessThanOrEqualTo(0.025)
)
// This can represent a "pinch" gesture trigger
```
### HSController
The `HSController` class is the **core orchestrator** of HandSuite.  
It manages **ARKit hand tracking sessions**, updates both hands in real-time, and handles the **gesture recognition pipeline**.
#### Responsabilities
- Initializes and runs **ARKit’s hand tracking session**
- Provides synchronized updates for both `HSHand` instances (`leftHand` and `rightHand`)
- Registers, removes, and processes custom gestures (`HSGestureScheme`)
- Adds tracked hands into a `RealityView` for visualization or debugging

#### Key Methods
 - `requestAuthorization()`
Requests user authorization for hand tracking.
```swift
Task {
    await controller.requestAuthorization()
}
```
 - `run()`
Starts the ARKit hand tracking session and listens for continuous updates.
This function must be called once, typically in .task or .onAppear.
```swift
Task {
    await controller.run()
}
```
- `addToContent(_:)`
Adds both the left and right hand joint models to the RealityKit content.
Useful for debugging or displaying hand skeletons in 3D space.
```swift
RealityView { content in
    controller.addToContent(content)
}
```
- `install(gesture:)`
Registers a new gesture recognizer conforming to HSGestureScheme.
```swift
controller.install(gesture: PinchGesture())
```
- `remove(gesture:)`
Removes a previously installed gesture recognizer.
```swift
controller.remove(gesture: PinchGesture())
```
- `processGestures()`
Evaluates all installed gestures against the current hand states.
Each gesture runs its recognition logic depending on its declared chirality (.left, .right, or .either).
```swift
controller.processGestures()
```
#### Example usage
```swift
 @Environment(HSController.self) var controller: HSController
    var body: some View {
        .task {
            await controller.requestAuthorization()
        }
    }
```
## Gestures (OnGoing)
The Gesture folder contain information for the Gesture process and values that allow that process.
- HSGestureScheme
- HSHandGesture
- HSDirection
- HSFingerDescription
- HSGestureDescription
- HSGestureStepDescription

### HSGestureScheme
The `HSGestureScheme` protocol defines the base contract for custom gesture recognition in HandSuite.  
Any gesture that you want to detect (e.g. fist) must conform to this protocol.

#### Responsabilities
- Defines gesture configuration and recognition logic.  
- Determines if a gesture has been recognized in the current frame.  
- Provides a consistent interface for gesture installation and processing inside `HSController`.  
- Evaluates finger states, directions, and joint distance constraints using `HSGestureDescription`.

#### Inicialization and Use
```swift
final class PinchGesture: HSGestureScheme {
    var chirality: HSChirality = .either
    var direction: HSDirection = .front
    var recognitionEvents: HSHandsEvents = .init()

    var description: HSGestureDescription {
        .hand(
            direction: .front,
            fingers: [
                .init(name: .thumb, state: .neutral, curlness: 0.40),
                .init(name: .index, state: .neutral, curlness: 0.40)
            ],
            jointComparisons: [
                HSJointComparison(
                    firstFinger: .thumb,
                    firstJoint: .tip,
                    secondFinger: .index,
                    secondJoint: .tip,
                    constraint: .lessThanOrEqualTo(0.025)
                )
            ]
        )
    }

    func recognize(in hand: HSHand) async {
        recognize(in: hand) // Uses default logic from protocol extension
    }
}
```
#### Key Methods
- `recognize(in:)`
Evaluates whether the gesture is recognized based on the current state of the given hand.
Checks finger curlness, state, direction, and optional joint distance constraints.
```swift
await gesture.recognize(in: controller.leftHand)

```
#### Examples of Usage
```swift
let pinchGesture = PinchGesture()
controller.install(gesture: pinchGesture)

RealityView { content in
    controller.addToContent(content)
}
.task {
    await controller.run()

    while true {
        await MainActor.run {
            controller.processGestures()
            if pinchGesture.wasRecognized {
                print("pinch gesture detected")
            }
        }
        try? await Task.sleep(for: .milliseconds(16)) // ~60 FPS
    }
}

```
## Utils
The Core folder contains utilitaries and miscellaneous from HandSuite.
- Constants
- Extensions

### Constants
#### Thresholds
The `Thresholds` enum defines key constants used by HandSuite’s gesture and finger calculations.  
These values determine how **finger curlness** and **state transitions** are interpreted during hand tracking.
##### Purpose

`Thresholds` provides standardized limits for:
- Measuring how much a finger is **bent (curlness)**  
- Deciding when a finger should be considered **straight** or **curled**

##### Constants

| Constant | Type | Description |
|-----------|------|-------------|
| `maxCurlness` | `Float` | Maximum expected curlness value (`0.5`), corresponding roughly to a 90° finger bend based on cosine similarity. |
| `curlnessLimitToStraight` | `Float` | Threshold (`0.15`) below which a finger is considered **straight** rather than curled. |

### Extensions 
The Extensions module provides small but essential utilities that support HandSuite’s core functionality.  
It includes mappings for ARKit skeleton joints, geometry helpers, color conversion, and math extensions.

#### HandSkeleton
The `HandSkeleton` dictionary maps **HandSuite joint names** (`HSJoint.Name`) to **ARKit’s `HandSkeleton.JointName`**.  
It ensures each `HSFinger` and `HSJoint` is correctly bound to ARKit’s underlying skeleton structure.

#### ModelEntity
A convenience method to generate a small RealityKit sphere with a given color and radius.
Used throughout HandSuite for debugging and visualizing joint positions.
```swift
let sphere = ModelEntity.createSphere(radius: 0.006, hexColor: "FF5733")
content.add(sphere)
```

#### SIMD3 Extensions
Adds extra math convenience to SIMD3<Float>:
distance(to:). Calculates the Euclidean distance between two 3D points.
