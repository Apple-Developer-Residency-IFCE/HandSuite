//
//  GestureStepDescription.swift
//  HandTracker
//
//  Created by Pedro Sousa on 27/11/24.
//

import Foundation

public extension HandSuiteTools {
    struct GestureStepDescription {
        public let isSimultaneous: Bool
        public let gesture: any HandSuiteTools.GestureScheme
    }
}
