//
//  DebuggerButton.swift
//  HandSuite
//
//  Created by Pedro Sousa on 24/10/25.
//

import SwiftUI

struct DebuggerButton: View {
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
    DebuggerButton(systemImage: "chevron.up") {
        print("Action!!!")
    }
}
