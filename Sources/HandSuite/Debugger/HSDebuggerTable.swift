import SwiftUI

struct HSDebuggerTable: View {
    @State var hand: HSHand

    var body: some View {
        VStack {
            Text("Chirality: \(hand.chirality.rawValue.capitalized)")

            Divider()

            Grid(horizontalSpacing: 12, verticalSpacing: 4) {
                GridRow {
                    Text("Finger")
                    Text("Curl")
                    Text("Direction")
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Divider()

                ForEach(HSFinger.Name.allCases, id: \.self) { fingerName in
                    GridRow {
                        Text(fingerName.rawValue.capitalized)
                        Text(hand.fingers[fingerName]?.state.rawValue ?? "-")
                        Text(hand.fingers[fingerName]?.direction.rawValue ?? "-")
                    }
                    .font(.caption)
                }
            }
            .gridCellUnsizedAxes([.horizontal, .vertical])
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGroupedBackground))
            }
        }
    }
}

#Preview {
    HSDebuggerTable(hand: HSHand(chirality: .right))
        .frame(width: 250, height: 250)
        .glassBackgroundEffect()
        
}
