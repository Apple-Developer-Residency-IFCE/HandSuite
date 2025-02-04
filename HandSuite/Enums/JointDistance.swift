//
//  Distance.swift
//  HandTracker
//
//  Created by Samuel Sales  on 22/01/25.
//

public extension HandSuiteTools {
    enum JointDistanceConstraint {
        case greaterThanOrEqualTo(_ distance: Float)
        case lessThanOrEqualTo(_ distance: Float)
    }
}
