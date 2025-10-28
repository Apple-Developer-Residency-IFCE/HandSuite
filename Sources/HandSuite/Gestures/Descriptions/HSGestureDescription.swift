import Foundation

public enum HSGestureDescription: Sendable {
    case hand(HSDirection, Set<HSFingerDescription>, [HSJointComparison])
    case finger(HSFingerDescription)
    case steps([HSGestureStepDescription])
}
