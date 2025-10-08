import ARKit
import HandSuite
import RealityKit
import SwiftUI

struct HSView: View {
    let isDebugModeEnable: Bool
    let gestureModel: GestureModel

    @State private var xAxis: Double = 30
    @State private var yAxis: Double = 30
    @State private var xPositioning: Double = 0.1   // expected in [-1, 1]
    @State private var yPositioning: Double = 0.1
    @State private var showSettings = false

    var make: (inout RealityViewContent) -> Void
    var update: (inout RealityViewContent) -> Void

    @Environment(HandSuiteTools.Tracker.self) private var tracker

    private let minW: CGFloat = 560
    private let minH: CGFloat = 420

    init(
        isDebugModeEnable: Bool = false,
        gestureModel: GestureModel,
        make: @escaping (inout RealityViewContent) -> Void,
        update: @escaping (inout RealityViewContent) -> Void = { _ in }
    ) {
        self.isDebugModeEnable = isDebugModeEnable
        self.gestureModel = gestureModel
        self.make = make
        self.update = update
    }

    var body: some View {
        RealityView { content, attachments in
            if isDebugModeEnable { tracker.addToContent(content) }
            make(&content)

            if isDebugModeEnable,
               let hud = attachments.entity(for: "debugHUD")
            {
                var billboard = BillboardComponent()
                billboard.blendFactor = 0
                hud.components.set(billboard)

                let head = AnchorEntity(.head)
                let pivot = Entity()
                pivot.name = "hudPivot"
                head.addChild(pivot)
                pivot.addChild(hud)
                content.add(head)
            }

        } update: { content, attachments in
            // MARK: - Update phase
            guard isDebugModeEnable,
                  let hud = attachments.entity(for: "debugHUD"),
                  let pivot = hud.parent
            else {
                update(&content)
                return
            }

            @inline(__always)
            func clamp(_ v: Float, _ a: Float, _ b: Float) -> Float { min(max(v, a), b) }

            let nx = clamp(Float(xPositioning), -1.5, 1.5)
            let ny = clamp(Float(yPositioning), -1.5, 1.5)

            let maxX: Float = 0.15
            let maxY: Float = 0.18
            let baseZ: Float = -0.40

            pivot.position = SIMD3<Float>(nx * maxX, ny * maxY, baseZ)

            update(&content)
        } attachments: {
            if isDebugModeEnable {
                Attachment(id: "debugHUD") {
                    ZStack {
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
                        .frame(width: max(minW, 200), height: max(minH, 200))

                        if showSettings {
                            CustomDebugView(
                                xAxis: $xAxis,
                                xPositioning: $xPositioning,
                                yPositioning: $yPositioning
                            )
                            .frame(width: max(minW, 200), height: max(minH, 200))
                            .compositingGroup()
                            .contentShape(Rectangle())
                            .padding(40)
                            .allowsHitTesting(true)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                    .allowsHitTesting(true)
                    .clipped(antialiased: false)
                }
            }
        }
    }
}

