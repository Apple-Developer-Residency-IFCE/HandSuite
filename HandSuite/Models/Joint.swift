//
//  Joint.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import ARKit
import RealityKit

public extension Hand {
    final class Joint: @unchecked Sendable {
        public let name: Hand.Joint.Name
        public let skeleton: HandSkeleton.JointName
        
        private var currentPosition: SIMD3<Float>?

        @MainActor public private(set) var model: ModelEntity?
        public private(set) weak var finger: Hand.Finger?

        init(name: Hand.Joint.Name, finger: Hand.Finger) {
            self.name = name
            self.skeleton = HandSkeleton.reciprocal[finger.name]![name]!
            self.finger = finger
        }

        @MainActor
        public func setModel(_ model: ModelEntity) {
            self.model = model
        }

        @MainActor
        public func getModelTransform() -> Transform? {
            return self.model?.transform
        }

        @MainActor
        public func setModelTransform(_ transform: Transform) {
            self.model?.transform = transform
            self.currentPosition = transform.translation
        }
        
        public func getCurrentPosition() -> SIMD3<Float>? {
            return currentPosition
        }
    }
}

public extension Hand.Joint {
    enum Name: String, CaseIterable {
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
