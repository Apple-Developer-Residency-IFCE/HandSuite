import SwiftUI
import ARKit
import RealityKit

@Observable
public final class HSHand: @unchecked Sendable {
    public let chirality: HSChirality
    @ObservationIgnored public private(set) var currentAnchor: HandAnchor?

    public private(set) var thumb: HSFinger?
    public private(set) var indexFinger: HSFinger?
    public private(set) var middleFinger: HSFinger?
    public private(set) var ringFinger: HSFinger?
    public private(set) var littleFinger: HSFinger?

    public private(set) var direction: HSDirection = .any
    public private(set) var fingers: [HSFinger.Name: HSFinger] = [:]
    public private(set) var joints: [HandSkeleton.JointName: HSJoint] = [:]

    public init(chirality: HSChirality) {
        self.chirality = chirality
        self.setUp()
    }

    private func setUp() {
        self.thumb = HSFinger(name: .thumb, hand: self)
        self.fingers[.thumb] = thumb

        self.indexFinger = HSFinger(name: .index, hand: self)
        self.fingers[.index] = indexFinger

        self.middleFinger = HSFinger(name: .middle, hand: self)
        self.fingers[.middle] = middleFinger

        self.ringFinger = HSFinger(name: .ring, hand: self)
        self.fingers[.ring] = ringFinger

        self.littleFinger = HSFinger(name: .little, hand: self)
        self.fingers[.little] = littleFinger

        for (_, finger) in self.fingers {
            for (_, joint) in finger.joints {
                self.joints[joint.skeleton] = joint
            }
        }
    }

    // TODO: Create a HandSuite View with RealiView.update, .onAppear, and .task in order to create less boilerplate code in client code
    @MainActor
    func addToContet(_ content: RealityKit.RealityViewContent) {
        for (_, joint) in joints {
            let sphere: ModelEntity = .createSphere()
            sphere.name = self.chirality.rawValue.capitalized + (joint.finger?.name.rawValue ?? "").capitalized + joint.name.rawValue.capitalized
            joint.update3DAsset(sphere)
            if let model = joint.model {
                content.add(model)
            }
        }
    }

    @MainActor
    func update(using anchor: HandAnchor) async {
        self.currentAnchor = anchor
        for (_, finger) in fingers {
            await finger.update(using: anchor)
        }
        self.direction = getPalmDirection()
    }

    func getFinger(named name: HSFinger.Name) -> HSFinger {
        return self.fingers[name]!
    }

    func getPalmDirection() -> HSDirection {
        guard let indexBase = joints[.indexFingerMetacarpal]?.currentPosition,
              let ringBase = joints[.ringFingerMetacarpal]?.currentPosition,
              let littleBase = joints[.littleFingerMetacarpal]?.currentPosition else {
            return .any
        }

        let vectorA = ringBase - indexBase
        let vectorB = littleBase - ringBase
        let normal = simd_normalize(simd_cross(vectorB, vectorA))
        let finalNormal = (chirality == .right) ? normal : -normal
        let cameraForward = simd_float3(0, 0, -1)
        let worldUp = simd_float3(0, 1, 0)
        let cameraRight = simd_float3(1, 0, 0)
        let dotForward = simd_dot(finalNormal, cameraForward)
        let dotUp = simd_dot(finalNormal, worldUp)
        let dotRight = simd_dot(finalNormal, cameraRight)
        let absForward = abs(dotForward)
        let absUp = abs(dotUp)
        let absRight = abs(dotRight)

        if absForward >= 0.45 {
            return dotForward > 0 ? .back : .front
        } else if absUp >= absRight {
            return dotUp > 0 ? .down : .up
        } else if absRight >= absUp {
            return dotRight > 0 ? .left : .right
        }

        return .any
    }
}
