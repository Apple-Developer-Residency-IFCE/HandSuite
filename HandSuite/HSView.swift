import ARKit
import HandSuite
import RealityKit
import SwiftUI

struct HSView: View {
    let isDebugModeEnable: Bool
    let gestureModel: GestureModel

    @Binding var xAxis: Double
    @Binding var yAxis: Double
    
    @Binding var xPositioning: Double
    @Binding var yPositioning: Double

    var make: (inout RealityViewContent) -> Void
    var update: (inout RealityViewContent) -> Void

    @Environment(HandSuiteTools.Tracker.self) private var tracker

    // ⬇️ NEW: minimums for the attachment view
    private let minW: CGFloat = 160
    private let minH: CGFloat = 120
    
    @State private var showSettings = false

    init(
        isDebugModeEnable: Bool = false,
        gestureModel: GestureModel,
        xAxis: Binding<Double>,
        yAxis: Binding<Double>,
        yPositioning: Binding<Double>,
        xPositioning: Binding<Double>,
        make: @escaping (inout RealityViewContent) -> Void,
        update: @escaping (inout RealityViewContent) -> Void = { _ in }
    ) {
        self.isDebugModeEnable = isDebugModeEnable
        self.gestureModel = gestureModel
        self._xAxis = xAxis
        self._yAxis = yAxis
        self._xPositioning = xPositioning
        self._yPositioning = yPositioning
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
                    HStack{
                        DebugView(
                            id: 0,
                            gestureModel: gestureModel,
                            xAxis: $xAxis,
                            yAxis: $yAxis,
                            showSettings: $showSettings
                        )
                        .padding(8)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 8)
                        // ⬇️ CHANGED: clamp to minimums (and make size non-negative)
                        .frame(
                            width:  max(CGFloat(abs(xAxis)) * 60 / 5, minW),   // = max(|x|*12, 160)
                            height: max(CGFloat(abs(yAxis)) * 35 / 5, minH),   // = max(|y|*7, 120)
                        )
                        if showSettings {                        // ⬅️ conditionally show
                                                    CustomDebugView(
                                                        xAxis: $xAxis,
                                                        xPositioning: $xPositioning,
                                                        yPositioning: $yPositioning
                                                    )
                                                }
                    }
                    
                }
            }
        }
    }
}

