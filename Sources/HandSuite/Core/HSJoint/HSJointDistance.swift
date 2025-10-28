import Foundation

public enum HSJointDistanceConstraint: Sendable {
    case greaterThanOrEqualTo(_ distance: Float)
    case lessThanOrEqualTo(_ distance: Float)
}
