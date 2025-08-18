//
//  HandGesture.swift
//  HandTracker
//
//  Created by Pedro Sousa on 26/11/24.
//

import SwiftUI

public extension HandSuiteTools {
    @Observable
    class HandGesture: HandSuiteTools.GestureScheme {        
        public let chirality:  HandSuiteTools.Chirality
        public let direction: HandSuiteTools.Direction
        public let description: HandSuiteTools.GestureDescription

        public var recognitionEvents: HandSuiteTools.HandsEvents
        
        @MainActor
        public init(
            chirality: HandSuiteTools.Chirality = .either,
            direction: HandSuiteTools.Direction = .any,
            
            description: HandSuiteTools.GestureDescription
        ) {
            self.chirality = chirality
            self.direction = direction
            self.description = description
            self.recognitionEvents = .init()
        }

        @MainActor
        public init(chirality: HandSuiteTools.Chirality = .either,
                    direction: HandSuiteTools.Direction = .any,
                    _ description: Set<HandSuiteTools.FingerDescription>,
                    jointComparisons: [HandSuiteTools.JointComparison] = []) {
            self.chirality = chirality
            self.direction = direction
            self.description = .hand(direction, description, jointComparisons)
            self.recognitionEvents = .init()
        }
    }
}
