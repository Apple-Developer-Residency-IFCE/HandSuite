import SwiftUI
import HandSuite

@main
struct SandboxApp: App {

    @State private var appModel = AppModel()
    let controller = HSController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(controller)
                .environment(appModel)
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(controller)
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
