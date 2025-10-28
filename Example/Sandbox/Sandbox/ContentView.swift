import SwiftUI
import RealityKit
import HandSuite

struct ContentView: View {
    @Environment(HSController.self) var controller: HSController

    var body: some View {
        VStack {
            ToggleImmersiveSpaceButton()
        }
        .padding()
        .task {
            await controller.requestAuthorization()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(HSController())
        .environment(AppModel())
}
