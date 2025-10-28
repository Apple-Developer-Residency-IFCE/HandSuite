import RealityKit
import SwiftUI

public struct HSDebuggerRealityView: View {
    @Binding var isDebugModeEnable: Bool

    @State private var xAxis: Double = 30
    @State private var yAxis: Double = 30
    @State private var xPositioning: Double = 0.1
    @State private var yPositioning: Double = 0.1

    var make: (inout RealityViewContent) -> Void
    var update: (inout RealityViewContent) -> Void

    var controller: HSController

    public init(
        controller: HSController,
        isDebugModeEnable: Binding<Bool>,
        make: @escaping (inout RealityViewContent) -> Void,
        update: @escaping (inout RealityViewContent) -> Void = { _ in }
    ) {
        self.controller = controller
        self._isDebugModeEnable = isDebugModeEnable
        self.make = make
        self.update = update
    }

    public var body: some View {
        RealityView { content in
            make(&content)

            guard isDebugModeEnable else { return }

            controller.addToContent(content)
            
            let hud = Entity()
            hud.name = "HUDDebugger"

            var billboard = BillboardComponent()
            billboard.blendFactor = 0
            hud.components.set(billboard)

            let debuggerAttachment = ViewAttachmentComponent(rootView: HSDebuggerView(controller: controller,
                                                                                      xPosition: $xPositioning,
                                                                                      yPosition: $yPositioning))
            hud.components.set(debuggerAttachment)
            content.add(hud)

            let head = AnchorEntity(.head)
            head.name = "HUDAnchor"
            head.addChild(hud)
            content.add(head)
        } update: { content in
            update(&content)

            guard isDebugModeEnable,
                  let pivot = content.entities.first(where: { $0.name == "HUDDebugger" })
            else { return }

            @inline(__always)
            func clamp(_ v: Float, _ a: Float, _ b: Float) -> Float { min(max(v, a), b) }

            let nx = clamp(Float(xPositioning), -1.5, 1.5)
            let ny = clamp(Float(yPositioning), -1.5, 1.5)

            let maxX: Float = 0.15
            let maxY: Float = 0.18
            let baseZ: Float = -0.40

            pivot.position = SIMD3<Float>(nx * maxX, ny * maxY, baseZ)
        }
    }
}
