import Foundation

public struct HSGestureStepDescription: Sendable {
    public let isSimultaneous: Bool
    public let gesture: any HSGestureScheme
}
