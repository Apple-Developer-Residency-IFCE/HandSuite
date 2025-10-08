import ARKit
import HandSuite
import RealityKit
import SwiftUI

struct HSView: View {
    let isDebugModeEnable: Bool
    let gestureModel: GestureModel

    @Binding var xAxis: Double
    @Binding var yAxis: Double

    @Binding var xPositioning: Double   // expected in [-1, 1]
    @Binding var yPositioning: Double   // expected in [-1, 1]

    var make: (inout RealityViewContent) -> Void
    var update: (inout RealityViewContent) -> Void

    @Environment(HandSuiteTools.Tracker.self) private var tracker

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

            // Create anchor + pivot ONCE and parent the HUD there
            if isDebugModeEnable,
               let hud = attachments.entity(for: "debugHUD")
            {
                var c = BillboardComponent()
                c.blendFactor = 0
                hud.components.set(c)

                let head = AnchorEntity(.head)
                let pivot = Entity()
                pivot.name = "hudPivot"
                
//                pivot.components.set(ViewAttachmentComponent(rootView: <#T##View#>))

                head.addChild(pivot)
                pivot.addChild(hud)          // HUD stays at local [0,0,0]
                content.add(head)
            }
        } update: { content, attachments in
            // Move the pivot EVERY FRAME based on dynamic x/y
            guard isDebugModeEnable,
                  let hud = attachments.entity(for: "debugHUD"),
                  let pivot = hud.parent      // <- the pivot we created
            else {
                update(&content)
                return
            }

            @inline(__always)
            func clamp(_ v: Float, _ a: Float, _ b: Float) -> Float { min(max(v, a), b) }

            let nx = clamp(Float(xPositioning), -1.5, 1.5)   // -1 left … +1 right
            let ny = clamp(Float(yPositioning), -1.5, 1.5)   // -1 down … +1 up (invert if needed)

            // Tune these (meters relative to head)
            let maxX: Float = 0.15
            let maxY: Float = 0.18
            let baseZ: Float = -0.40

            pivot.position = SIMD3<Float>(nx * maxX, ny * maxY, baseZ)

            update(&content)
        } attachments: {
            if isDebugModeEnable {
                Attachment(id: "debugHUD") {
                    HStack {
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
                        .frame(
                            width: max(CGFloat(abs(xAxis)) * 12, minW),
                            height: max(CGFloat(abs(yAxis)) * 8,  minH)
                        )

                        if showSettings {
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

