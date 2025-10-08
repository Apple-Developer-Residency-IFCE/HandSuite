import SwiftUI
struct CustomDebugView: View {
    @Binding var xAxis: Double
    @Binding var xPositioning: Double
    @Binding var yPositioning: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let marginY: CGFloat = 28 // adjust feel here
            let marginX: CGFloat = -22

            ZStack {
                // Y axis buttons (top/bottom)
                controlButton(systemImage: "chevron.up") { yPositioning += 0.1 }
                    .position(x: width / 2, y: marginY)

                controlButton(systemImage: "chevron.down") { yPositioning -= 0.1 }
                    .position(x: width / 2, y: height - marginY)

                // X axis buttons (left/right)
                controlButton(systemImage: "chevron.left") { xPositioning -= 0.1 }
                    .position(x: marginX, y: height / 2)

                controlButton(systemImage: "chevron.right") { xPositioning += 0.1 }
                    .position(x: width - marginX, y: height / 2)
            }
            .frame(width: width, height: height)
            .allowsHitTesting(false)
        }
    }

    private func controlButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.title2)
                .frame(width: 40, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(true)
    }
}

