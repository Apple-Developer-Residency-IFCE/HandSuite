//
//  GestureRecognitionEvent.swift
//  HandTracker
//
//  Created by Pedro Sousa on 28/11/24.
//

import Foundation
import ARKit

public extension HandSuiteTools {
    struct HandEvent {
        public let wasRecognized: Bool
        public let hand: Hand

        public var anchor: HandAnchor? { hand.currentAnchor }
    }

    struct HandsEvents {
        public var leftHand: HandEvent?
        public var rightHand: HandEvent?
    }
}

extension HandSuiteTools.HandEvent: Hashable {
    public static func == (lhs: HandSuiteTools.HandEvent, rhs: HandSuiteTools.HandEvent) -> Bool {
        lhs.hand.chirality == rhs.hand.chirality
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.hand.chirality)
        hasher.combine(self.wasRecognized)
    }
}
