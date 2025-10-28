import Foundation
import ARKit

public struct HSHandEvent: Sendable, Hashable {
    public let wasRecognized: Bool
    public let hand: HSHand
    public var anchor: HandAnchor? { hand.currentAnchor }

    public static func == (lhs: HSHandEvent, rhs: HSHandEvent) -> Bool {
        lhs.hand.chirality == rhs.hand.chirality
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hand.chirality)
        hasher.combine(self.wasRecognized)
    }
}

public struct HSHandsEvents: Sendable {
    public var leftHand: HSHandEvent?
    public var rightHand: HSHandEvent?
}
