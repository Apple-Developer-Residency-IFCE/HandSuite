import Observation
import SwiftUI

public struct HSDebuggerView: View {
    private let id: UUID = UUID()

    let controller: HSController

    @State private var showSettings: Bool = false
    @State private var size: CGSize = .zero

    @Binding private var xPosition: Double
    @Binding private var yPosition: Double

    public init(controller: HSController,
                xPosition: Binding<Double>,
                yPosition: Binding<Double>) {
        self.controller = controller
        self._xPosition = xPosition
        self._yPosition = yPosition
    }
    
    public var body: some View {
        ZStack {
            VStack(spacing: 16) {
                header
                
                Divider()
                
                HStack(spacing: 20) {
                    HSDebuggerTable(hand: controller.leftHand)
                    Divider()
                    HSDebuggerTable(hand: controller.rightHand)
                }
            }
            .font(.system(.body, design: .monospaced))
            .padding(16)
            .glassBackgroundEffect()
            .frame(maxWidth: 480, maxHeight: 280)
            .onGeometryChange(for: CGSize.self, of: { proxy in
                proxy.size
            }, action: { newSize in
                size = newSize
            })

            if showSettings {
                controls
            }
        }
        .frame(width: 480, height: 280)
    }

    var header: some View {
        VStack {
            HStack {
                ZStack {
                    Text("Debugger")
                        .font(.title3)
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation {
                                showSettings.toggle()
                            }
                        } label: {
                            Label("Setting", systemImage: "gear")
                                .labelStyle(.iconOnly)
                        }
                    }
                }
            }
        }
    }

    var controls: some View {
        VStack {
            HSDebuggerButton(systemImage: "chevron.up") {
                yPosition += 0.1
            }
            
            HStack {
                HSDebuggerButton(systemImage: "chevron.left") {
                    xPosition -= 0.1
                }
                
                Spacer()
                    .frame(width: size.width, height: size.height)
                    .padding(8)
                
                HSDebuggerButton(systemImage: "chevron.right") {
                    xPosition += 0.1
                }
            }
            
            HSDebuggerButton(systemImage: "chevron.down") {
                yPosition -= 0.1
            }
        }
    }
}

#Preview {
    @Previewable @State var xPosition: Double = 0.0
    @Previewable @State var yPosition: Double = 0.0

    HSDebuggerView(controller: .init(),
                   xPosition: $xPosition,
                   yPosition: $yPosition)
}


