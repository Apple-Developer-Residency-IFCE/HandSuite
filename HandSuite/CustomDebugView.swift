import SwiftUI

struct CustomDebugView: View {
    @Binding var xAxis: Double
    @Binding var xPositioning: Double
    @Binding var yPositioning: Double
    var onClose: (() -> Void)? = nil

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let marginY: CGFloat = 24
            let marginX: CGFloat = 16

            ZStack {
                Color.clear
//                if let onClose {
//                    Button {
//                        onClose()
//                    } label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .frame(width: 20, height: 20)
//                            .background(.ultraThinMaterial, in: Circle())
//                            .shadow(radius: 2)
//                    }
//                    .position(x: width - marginX, y: marginY)
//                }

                controlButton(systemImage: "chevron.up") { yPositioning += 0.1 }
                    .position(x: width / 2, y: marginY)

                controlButton(systemImage: "chevron.down") { yPositioning -= 0.1 }
                    .position(x: width / 2, y: height - marginY)

                controlButton(systemImage: "chevron.left") { xPositioning -= 0.1 }
                    .position(x: -marginX, y: height / 2)

                controlButton(systemImage: "chevron.right") { xPositioning += 0.1 }
                    .position(x: width + marginX, y: height / 2)
            }
            .frame(width: width, height: height)
            .allowsHitTesting(true)
        }
    }

    private func controlButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title3)
                .frame(width: 30, height: 30)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
    }
}

