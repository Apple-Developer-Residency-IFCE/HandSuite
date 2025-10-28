import SwiftUI
import RealityKit
import HandSuite

struct ImmersiveView: View {
    @State private var isDebugModeEnable = true
    @Environment(HSController.self) var controller: HSController

    var body: some View {
//        HSDebuggerRealityView(controller: controller,
//                              isDebugModeEnable: $isDebugModeEnable) { content in
//            // Use content.add(_) if needed
//        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(HSController())
        .environment(AppModel())
}
