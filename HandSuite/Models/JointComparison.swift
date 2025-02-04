//
//  JointDistance.swift
//  HandTracker
//
//  Created by Samuel Sales  on 22/01/25.
//

public extension HandSuiteTools {
    struct JointComparison {
        public let firstFinger: Hand.Finger.Name
        public let firstJoint: Hand.Joint.Name
        
        public let secondFinger: Hand.Finger.Name
        public let secondJoint: Hand.Joint.Name
        
        public let constraint: HandSuiteTools.JointDistanceConstraint
        
        public init(firstFinger: Hand.Finger.Name,
                    firstJoint: Hand.Joint.Name,
                    secondFinger: Hand.Finger.Name,
                    secondJoint: Hand.Joint.Name,
                    constraint: HandSuiteTools.JointDistanceConstraint) {
            self.firstFinger = firstFinger
            self.firstJoint = firstJoint
            self.secondFinger = secondFinger
            self.secondJoint = secondJoint
            self.constraint = constraint
        }
    }
}
