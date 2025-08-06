//
//  Finger.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import ARKit
import RealityKit

public extension Hand {
    @Observable
    final class Finger: @unchecked Sendable {
        public let name: Hand.Finger.Name

        public private(set) weak var hand: Hand?

        public private(set) var direction: HandSuiteTools.Direction = .any
        public private(set) var state: HandSuiteTools.State = .neutral
        public private(set) var curlness: Float = 0.0
        
        @ObservationIgnored public private(set) var knuckle: Hand.Joint?
        @ObservationIgnored public private(set) var intermediateBase: Hand.Joint?
        @ObservationIgnored public private(set) var metacarpal: Hand.Joint?
        @ObservationIgnored public private(set) var intermediateTip: Hand.Joint?
        @ObservationIgnored public private(set) var tip: Hand.Joint?
        
        @ObservationIgnored public private(set) var joints: [Hand.Joint.Name: Hand.Joint] = [:]

        init(name: Hand.Finger.Name, hand: Hand) {
            self.name = name
            self.hand = hand
            self.setUp()
        }

        private func setUp() {
            self.knuckle = Hand.Joint(name: .knuckle, finger: self)
            self.joints[.knuckle] = self.knuckle
            
            self.intermediateBase = Hand.Joint(name: .intermediateBase, finger: self)
            self.joints[.intermediateBase] = self.intermediateBase
            
            self.intermediateTip = Hand.Joint(name: .intermediateTip, finger: self)
            self.joints[.intermediateTip] = self.intermediateTip
            
            self.tip = Hand.Joint(name: .tip, finger: self)
            self.joints[.tip] = self.tip
            
            self.metacarpal = name != .thumb ? Hand.Joint(name: .metacarpal, finger: self) : nil
            self.joints[.metacarpal] = self.metacarpal
        }

        @MainActor
        public func update(using anchor: HandAnchor) async {
            self.updateJoints(using: anchor)

            self.curlness = await getCurlAmount() / 0.5
            self.state = self.curlness > 0.15 ? .curl : .straight
            
            let directionVector = calculateFingerDirection()
            self.direction = updateDirection(from: directionVector)
        }

        @MainActor
        func updateJoints(using anchor: HandAnchor) {
            for (_, joint) in joints {
                if let skeleton = anchor.handSkeleton?.joint(joint.skeleton),
                   skeleton.isTracked {
                    let matrix = matrix_multiply(anchor.originFromAnchorTransform, skeleton.anchorFromJointTransform)
                    let transform = Transform(matrix: matrix)
                    joint.setModelTransform(transform)
                }
            }
        }
        
        public func getJoint(named name: Hand.Joint.Name) -> Joint? {
            return self.joints[name]
        }
        
        private func updateDirection(from vector: SIMD3<Float>?) -> HandSuiteTools.Direction {
            guard let vector = vector, length(vector) > 0.0001 else {
                return .any // fallback
            }

            let referenceVectors: [HandSuiteTools.Direction: SIMD3<Float>] = [
                .up:    SIMD3(0, 1, 0),
                .down:  SIMD3(0, -1, 0),
                .left:  SIMD3(-1, 0, 0),
                .right: SIMD3(1, 0, 0),
                .front: SIMD3(0, 0, -1),
                .back:  SIMD3(0, 0, 1)
            ]

            return referenceVectors.max(by: {
                dot(normalize(vector), $0.value) < dot(normalize(vector), $1.value)
            })?.key ?? .any
        }
        
        private func calculateFingerDirection() -> SIMD3<Float>? {
            if let tip = tip?.getCurrentPosition(), let knuckle = knuckle?.getCurrentPosition() {
                return normalize(tip - knuckle)
            } else if let tip = intermediateTip?.getCurrentPosition(), let base = intermediateBase?.getCurrentPosition() {
                return normalize(tip - base)
            } else {
                return nil
            }
        }



        public func getCurlness() async -> Float {
            return self.curlness
        }

        private func getCurlAmount() async -> Float {
            let jointsTranslation = await [
                tip?.getModelTransform(),
                intermediateTip?.getModelTransform(),
                intermediateBase?.getModelTransform(),
                knuckle?.getModelTransform()
            ].compactMap { $0?.translation }

            return calculateCurlness(of: jointsTranslation)
        }

        private func calculateCurlness(of joints: [SIMD3<Float>]) -> Float {
            guard joints.count >= 3 else {
                return 0
            }
            
            var totalCurl: Float = 0
            let segmentCount = joints.count - 2
            
            for i in 0..<segmentCount {
                let first = joints[i]
                let middle = joints[i + 1]
                let last = joints[i + 2]

                let vector1 = normalize(middle - first)
                let vector2 = normalize(last - middle)
                
                let angle = acos(dot(vector1, vector2))
                let curl = 1 - abs(angle - .pi) / .pi
                
                totalCurl += curl
            }

            return totalCurl / Float(segmentCount)
        }
        
        public func updateDirection(_ newDirection: HandSuiteTools.Direction) {
            self.direction = newDirection
        }
    }
}

public extension Hand.Finger {
    enum Name: Int, CaseIterable {
        case thumb
        case index
        case middle
        case ring
        case little
    }
}
