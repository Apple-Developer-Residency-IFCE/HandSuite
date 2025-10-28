import SwiftUI

@MainActor @Observable
final class HSHandGesture: HSGestureScheme {
    public let chirality: HSChirality
    public let direction: HSDirection
    public let description: HSGestureDescription
    public var recognitionEvents: HSHandsEvents

    @MainActor
    public init(
        chirality: HSChirality = .either,
        direction: HSDirection = .any,
        description: HSGestureDescription
    ) {
        self.chirality = chirality
        self.direction = direction
        self.description = description
        self.recognitionEvents = .init()
    }

    @MainActor
    public init(chirality: HSChirality = .either,
                direction: HSDirection = .any,
                _ description: Set<HSFingerDescription>,
                jointComparisons: [HSJointComparison] = []) {
        self.chirality = chirality
        self.direction = direction
        self.description = .hand(direction, description, jointComparisons)
        self.recognitionEvents = .init()
    }
}
