import Foundation
import simd

public enum HSDirection: String, CaseIterable, Sendable {
    case any
    case up
    case down
    case left
    case right
    case front
    case back

    var cardinal: SIMD3<Float> {
        switch self {
        case .any: return SIMD3(0, 0, 0)
        case .up: return SIMD3(0, 1, 0)
        case .down: return SIMD3(0, -1, 0)
        case .left: return SIMD3(-1, 0, 0)
        case .right: return SIMD3(1, 0, 0)
        case .front: return SIMD3(0, 0, -1)
        case .back: return SIMD3(0, 0, 1)
        }
    }
}
