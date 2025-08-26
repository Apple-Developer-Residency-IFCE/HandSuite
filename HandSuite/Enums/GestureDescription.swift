//
//  GestureDescription.swift
//  HandTracker
//
//  Created by Pedro Sousa on 27/11/24.
//

import Foundation

public extension HandSuiteTools {
    enum GestureDescription {
        case hand(HandSuiteTools.Direction, Set<HandSuiteTools.FingerDescription>, [HandSuiteTools.JointComparison])
        case finger(HandSuiteTools.FingerDescription)
        case steps([HandSuiteTools.GestureStepDescription])
    }
}
