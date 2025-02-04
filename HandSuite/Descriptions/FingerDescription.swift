//
//  FingerDescription.swift
//  HandTracker
//
//  Created by Pedro Sousa on 26/11/24.
//

import Foundation

public extension HandSuiteTools {
    struct FingerDescription {
        public let name: Hand.Finger.Name
        public let curlness: Float
        public let state: HandSuiteTools.State
        public let direction: HandSuiteTools.Direction

        public init(name: Hand.Finger.Name,
             curlness: Float = 0.0,
             state: HandSuiteTools.State = .neutral,
             direction: HandSuiteTools.Direction = .any) {
            self.name = name
            self.curlness = curlness
            self.state = state
            self.direction = direction
        }
    }
}

extension HandSuiteTools.FingerDescription: Hashable {
    public static func == (lhs: HandSuiteTools.FingerDescription, rhs: HandSuiteTools.FingerDescription) -> Bool {
        lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}
