import Foundation

public struct HSFingerDescription: Sendable, Hashable {
    public let name: HSFinger.Name
    public let curlness: Float
    public let state: HSState
    public let direction: HSDirection

    public init(
        name: HSFinger.Name,
        curlness: Float = 0.0,
        state: HSState = .neutral,
        direction: HSDirection = .any) {
        self.name = name
        self.curlness = curlness
        self.state = state
        self.direction = direction
    }

    public static func == (lhs: HSFingerDescription, rhs: HSFingerDescription) -> Bool {
        lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.name)
    }
}
