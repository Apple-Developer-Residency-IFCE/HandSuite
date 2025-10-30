
# HandSuite - Apple Developer Residency

HandSuite is a Package for VisionPro, that allows the user to manipulate the Hand information provided by RealityKit and ARKit. It expands the VisionPro usage of gestures letting the user creates they own costumized gestures to interact and build VisionPro apps.

# How to Install

At this moment, HandSuite only supports SPM. By this mean, you should:

- Clone the main branch: 
```
git clone https://github.com/Apple-Developer-Residency-IFCE/HandSuite.git
```
- Create a project in XCode and add the HandSuite as a local package.
A sample project is available inside the package. If you wan't to test with it, just open the `.xcodeproj` within the package and you should be good to go.

_The HandSuite Package is build for VisionPro, trying to run it in another device or the XCode Simulator may lead to malfunction._

# Documentation - In Progress
Here, you will know all files, objects, enums and structs available to be used in your projects. For now, we don't have a full Documentation for the project, partially because it stills being built.

## Sandbox
The Sandbox is our sample file to show the usage of HandSuite. By default, it's a simple Immersive Enviroment App. And this lead us to the first major information about HandSuite: _The HandSuite Package must be used within a ImmersiveSpace._

- ImmersiveView: Here, the most important thing is the usage of HSDebuggerRealityView, a View that shows the developer what's the VisionPro is seeing in terms of Direction, Curlness, and Position of the Fingers and the Hand it self.
```
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

The HSDebuggerRealityView receives the `HSController` responsible for handling the information listed above, to the user by the HSDebuggerRealityView. The `isDebugModeEnable` allows the user to enable or disable the DebugPanel.

## Core
Documentation on Progress;

## Gestures
Documentation on Progress;

## Utils
Documentation on Progress;
