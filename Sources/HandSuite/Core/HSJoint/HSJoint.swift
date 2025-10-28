import SwiftUI
import ARKit
import RealityKit

public final class HSJoint: @unchecked Sendable {
    public let name: HSJoint.Name
    public let skeleton: HandSkeleton.JointName
    private(set) var currentPosition: SIMD3<Float>?

    @MainActor public private(set) var model: ModelEntity?
    @MainActor public var modelTransform: Transform? { model?.transform }

    public private(set) weak var finger: HSFinger?

    init(name: HSJoint.Name, finger: HSFinger) {
        self.name = name
        self.skeleton = HandSkeleton.reciprocal[finger.name]![name]!
        self.finger = finger
    }

    @MainActor
    public func update3DAsset(_ model: ModelEntity) {
        self.model = model
    }

    @MainActor
    public func move(to transform: Transform) {
        self.model?.transform = transform
        self.currentPosition = transform.translation
    }
}

public extension HSJoint {
    enum Name: String, CaseIterable, Sendable {
        case intermediateBase
        case intermediateTip
        case metacarpal
        case knuckle
        case tip

        // TODO: Check if there is need to add these joints
//        case forearmArm
//        case forearmWrist
//        case wrist
    }
}
