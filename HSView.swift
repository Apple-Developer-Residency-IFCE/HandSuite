import SwiftUI
import ARKit
import RealityKit
import HandSuite

struct HSView: View {
    let isDebugModeEnable: Bool
    let gestureModel: GestureModel

    @Binding var xAxis: Double
    @Binding var yAxis: Double

    var make: (inout RealityViewContent) -> Void
    var update: (inout RealityViewContent) -> Void

    @Environment(HandSuiteTools.Tracker.self) private var tracker

    init(
        isDebugModeEnable: Bool = false,
        gestureModel: GestureModel,
        xAxis: Binding<Double>,
        yAxis: Binding<Double>,
        make: @escaping (inout RealityViewContent) -> Void,
        update: @escaping (inout RealityViewContent) -> Void = { _ in }
    ) {
        self.isDebugModeEnable = isDebugModeEnable
        self.gestureModel = gestureModel
        self._xAxis = xAxis
        self._yAxis = yAxis
        self.make = make
        self.update = update
    }

    var body: some View {
        RealityView { content, attachments in
            if isDebugModeEnable { tracker.addToContent(content) }
            make(&content)

            if isDebugModeEnable, let hud = attachments.entity(for: "debugHUD") {
                hud.components.set(BillboardComponent())
                hud.position = [0, 0.10, -0.9]
                let headAnchor = AnchorEntity(.head)
                headAnchor.addChild(hud)
                content.add(headAnchor)
            }
        } update: { content, _ in
            update(&content)
        } attachments: {
            if isDebugModeEnable {
                Attachment(id: "debugHUD") {
                    DebugView(id: 0, gestureModel: gestureModel, xAxis: $xAxis, yAxis: $yAxis)
                        .frame(width: xAxis * 10, height: yAxis * 10)
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                }
            }
        }
    }
}

