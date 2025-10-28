import Observation
import SwiftUI

public struct HSDebuggerView: View {
    private let id: UUID = UUID()

    let tracker: HandSuiteTools.Tracker

    @State private var showSettings: Bool = false
    @State private var xPosition: Double = 0
    @State private var yPosition: Double = 0
    @State private var size: CGSize = .zero

    public init(tracker: HandSuiteTools.Tracker) {
        self.tracker = tracker
    }

    public var body: some View {
        ZStack {
            VStack(spacing: 16) {
                header
                
                Divider()
                
                HStack(spacing: 20) {
                    DebuggerTable(hand: tracker.leftHand)
                    Divider()
                    DebuggerTable(hand: tracker.rightHand)
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
            DebuggerButton(systemImage: "chevron.up") {
                yPosition += 0.1
            }
            
            HStack {
                DebuggerButton(systemImage: "chevron.left") {
                    xPosition -= 0.1
                }
                
                Spacer()
                    .frame(width: size.width, height: size.height)
                    .padding(8)
                
                DebuggerButton(systemImage: "chevron.right") {
                    xPosition += 0.1
                }
            }
            
            DebuggerButton(systemImage: "chevron.down") {
                yPosition -= 0.1
            }
        }
    }
}

#Preview {
    HSDebuggerView(tracker: .init())
}


