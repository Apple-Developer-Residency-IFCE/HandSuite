//
//  Hand.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import ARKit
import RealityKit

@Observable
public final class Hand: @unchecked Sendable {
    public let chirality: HandSuiteTools.Chirality
    @ObservationIgnored public private(set) var currentAnchor: HandAnchor?

    public private(set) var thumb: Hand.Finger?
    public private(set) var indexFinger: Hand.Finger?
    public private(set) var middleFinger: Hand.Finger?
    public private(set) var ringFinger: Hand.Finger?
    public private(set) var littleFinger: Hand.Finger?

    public private(set) var direction: HandSuiteTools.Direction = .any
    public private(set) var fingers: [Hand.Finger.Name: Finger] = [:]
    public private(set) var joints: [HandSkeleton.JointName: Hand.Joint] = [:]

    public init(chirality: HandSuiteTools.Chirality) {
        self.chirality = chirality
        self.setUp()
    }

    private func setUp() {
        self.thumb = Hand.Finger(name: .thumb, hand: self)
        self.fingers[.thumb] = thumb

        self.indexFinger = Hand.Finger(name: .index, hand: self)
        self.fingers[.index] = indexFinger

        self.middleFinger = Hand.Finger(name: .middle, hand: self)
        self.fingers[.middle] = middleFinger

        self.ringFinger = Hand.Finger(name: .ring, hand: self)
        self.fingers[.ring] = ringFinger

        self.littleFinger = Hand.Finger(name: .little, hand: self)
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
            joint.setModel(.createSphere())
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

    func getFinger(named name: Hand.Finger.Name) -> Finger {
        return self.fingers[name]!
    }

    func getPalmDirection() -> HandSuiteTools.Direction {
        guard let indexBase = joints[.indexFingerMetacarpal]?.getCurrentPosition(),
              let ringBase = joints[.ringFingerMetacarpal]?.getCurrentPosition(),
              let littleBase = joints[.littleFingerMetacarpal]?.getCurrentPosition() else {
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
