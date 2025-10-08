import SwiftUI

struct CustomDebugView: View {
    @Binding var xAxis: Double
    //@Binding var yAxis: Double
    
    @Binding var xPositioning: Double
    @Binding var yPositioning: Double
    
    @State private var editingX = false
    @State private var editingY = false

    var body: some View {
        VStack(spacing: 12) {
            AxisRow(title: "Debug Window Width", value: $xAxis, range: 50...80, step: 1)
            AxisRow(title: "Debug Window Vertical Position", value: $yPositioning, range: -1...1, step: 1)
            AxisRow(title: "Debug Window Horizontal Position", value: $xPositioning, range: -1...1, step: 1)
//          AxisRow(title: "yAxis", value: $yAxis, isEditing: $editingY, range: 0...100, step: 1)
        }
        .padding(8) 
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(.separator, lineWidth: 1))
    }
}

private struct AxisRow: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(alignment: .leading)

            Slider(value: $value, in: range, step: step)
            .frame(maxWidth: 350, maxHeight: 50)
        }
    }
}

