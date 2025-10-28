import SwiftUI

struct HSDebuggerButton: View {
    var systemImage: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Action", systemImage: systemImage)
                .labelStyle(.iconOnly)
                .frame(width: 30, height: 30)
        }
        .shadow(radius: 2)
    }
}

#Preview {
    HSDebuggerButton(systemImage: "chevron.up") {
        print("Action!!!")
    }
}
