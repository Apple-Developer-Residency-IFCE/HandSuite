import SwiftUI
import HandSuite
import Observation

struct DebugView: View {
    let id: Int
    let gestureModel: GestureModel
    @Environment(HandSuiteTools.Tracker.self) private var tracker

    @Binding var xAxis: Double
    @Binding var yAxis: Double

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("xAxis: \(xAxis, specifier: "%.1f")")
                Text("yAxis: \(yAxis, specifier: "%.1f")")
            }

            HStack(spacing: 20) {
                table(title: "Left Hand", rows: [
                    ("Pinky", tracker.leftHand.littleFinger),
                    ("Ring", tracker.leftHand.ringFinger),
                    ("Middle", tracker.leftHand.middleFinger),
                    ("Index", tracker.leftHand.indexFinger),
                    ("Thumb", tracker.leftHand.thumb)
                ])

                table(title: "Right Hand", rows: [
                    ("Pinky", tracker.rightHand.littleFinger),
                    ("Ring", tracker.rightHand.ringFinger),
                    ("Middle", tracker.rightHand.middleFinger),
                    ("Index", tracker.rightHand.indexFinger),
                    ("Thumb", tracker.rightHand.thumb)
                ])
            }

            Divider()

            HStack(spacing: 12) {
                Text("Left Dir: \(String(describing: tracker.leftHand.direction))")
                Text("Right Dir: \(String(describing: tracker.rightHand.direction))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 12).stroke(.separator, lineWidth: 1))
        .font(.system(.body, design: .monospaced))
    }

    @ViewBuilder private func table(title: String, rows: [(String, Hand.Finger?)]) -> some View {
        VStack(spacing: 0) {
            Text(title).font(.largeTitle).padding(.bottom, 4)
            Divider()
            Grid(horizontalSpacing: 12, verticalSpacing: 4) {
                GridRow {
                    header("Finger")
                    header("Curl")
                    header("Direction")
                }
                Divider().gridCellUnsizedAxes([.horizontal, .vertical])

                ForEach(rows, id: \.0) { name, finger in
                    GridRow {
                        cell(name)
                        cell(finger?.state)
                        cell(finger?.direction)
                    }
                    Divider().gridCellUnsizedAxes([.horizontal, .vertical])
                }
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemGroupedBackground)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.separator, lineWidth: 1))
    }

    @ViewBuilder private func header(_ text: String) -> some View {
        Text(text).font(.caption).foregroundStyle(.secondary)
    }

    @ViewBuilder private func cell<T>(_ value: T?) -> some View {
        Text(value.map { String(describing: $0) } ?? "—")
            .lineLimit(1)
            .truncationMode(.tail)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 2)
    }
}

