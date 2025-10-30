import SwiftUI
import ARKit
import RealityKit

@Observable
public final class HSController: @unchecked Sendable {
    @ObservationIgnored private let session: ARKitSession
    @ObservationIgnored private let provider: HandTrackingProvider

    @MainActor private(set) var latestHandTracking: HSHandsEvents = .init()
    @MainActor @ObservationIgnored private var gestures: [any HSGestureScheme] = []

    public let leftHand = HSHand(chirality: .left)
    public let rightHand = HSHand(chirality: .right)

    public init(session: ARKitSession = .init(),
                provider: HandTrackingProvider = .init()) {
        self.session = session
        self.provider = provider
    }

    public func requestAuthorization() async {
        _ = await session.requestAuthorization(for: [.handTracking])
    }

    public func run() async {
        guard HandTrackingProvider.isSupported else { return }

        do {
            try await session.run([provider])
            for await update in provider.anchorUpdates {
                await handle(update)
            }
        } catch {
            print("HandSuite Error: \(error.localizedDescription)")
        }
    }

    private func handle(_ update: AnchorUpdate<HandAnchor>) async {
        switch update.event {
        case .updated:
            let anchor = update.anchor
            guard anchor.isTracked else { return }

            if anchor.chirality == .left {
                await self.leftHand.update(using: anchor)
            } else {
                await self.rightHand.update(using: anchor)
            }
        default:
            break
        }
    }

    @MainActor
    public func addToContent(_ content: RealityKit.RealityViewContent) {
        leftHand.addToContet(content)
        rightHand.addToContet(content)
    }

    @MainActor
    public func install(gesture: any HSGestureScheme) {
        self.gestures.append(gesture)
    }

    @MainActor
    public func remove(gesture: any HSGestureScheme) {
        self.gestures.removeAll { $0 === gesture }
    }

    @MainActor
    public func processGestures() {
        for gesture in gestures {
            if gesture.chirality == .left {
                gesture.recognize(in: self.leftHand)
            }

            if gesture.chirality == .right {
                gesture.recognize(in: self.rightHand)
            }

            if gesture.chirality == .either {
                gesture.recognize(in: self.leftHand)
                gesture.recognize(in: self.rightHand)
            }
        }
    }
}
