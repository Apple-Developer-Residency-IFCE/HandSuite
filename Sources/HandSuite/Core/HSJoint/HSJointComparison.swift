import Foundation

public struct HSJointComparison: Sendable {
    public let firstFinger: HSFinger.Name
    public let firstJoint: HSJoint.Name
    public let secondFinger: HSFinger.Name
    public let secondJoint: HSJoint.Name
    public let constraint: HSJointDistanceConstraint

    public init(firstFinger: HSFinger.Name,
                firstJoint: HSJoint.Name,
                secondFinger: HSFinger.Name,
                secondJoint: HSJoint.Name,
                constraint: HSJointDistanceConstraint) {
        self.firstFinger = firstFinger
        self.firstJoint = firstJoint
        self.secondFinger = secondFinger
        self.secondJoint = secondJoint
        self.constraint = constraint
    }
}
