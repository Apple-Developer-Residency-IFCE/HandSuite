import SwiftUI
import ARKit
import RealityKit

@Observable
public final class HSFinger: @unchecked Sendable {
    public let name: HSFinger.Name

    public private(set) weak var hand: HSHand?

    public private(set) var direction: HSDirection = .any
    public private(set) var state: HSState = .neutral
    public private(set) var curlness: Float = 0.0

    @ObservationIgnored public private(set) var knuckle: HSJoint?
    @ObservationIgnored public private(set) var intermediateBase: HSJoint?
    @ObservationIgnored public private(set) var metacarpal: HSJoint?
    @ObservationIgnored public private(set) var intermediateTip: HSJoint?
    @ObservationIgnored public private(set) var tip: HSJoint?
    @ObservationIgnored public private(set) var joints: [HSJoint.Name: HSJoint] = [:]

    init(name: HSFinger.Name, hand: HSHand) {
        self.name = name
        self.hand = hand
        self.setUp()
    }

    private func setUp() {
        self.knuckle = HSJoint(name: .knuckle, finger: self)
        self.joints[.knuckle] = self.knuckle

        self.intermediateBase = HSJoint(name: .intermediateBase, finger: self)
        self.joints[.intermediateBase] = self.intermediateBase

        self.intermediateTip = HSJoint(name: .intermediateTip, finger: self)
        self.joints[.intermediateTip] = self.intermediateTip

        self.tip = HSJoint(name: .tip, finger: self)
        self.joints[.tip] = self.tip

        self.metacarpal = name != .thumb ? HSJoint(name: .metacarpal, finger: self) : nil
        self.joints[.metacarpal] = self.metacarpal
    }

    @MainActor
    public func update(using anchor: HandAnchor) async {
        self.updateJoints(using: anchor)

        self.curlness = await getCurlAmount() / Thresholds.maxCurlness
        self.state = self.curlness > Thresholds.curlnessLimitToStraight ? .curl : .straight

        self.direction = updateDirection(from: calculateFingerDirection())
    }

    @MainActor
    func updateJoints(using anchor: HandAnchor) {
        for (_, joint) in joints {
            if let skeleton = anchor.handSkeleton?.joint(joint.skeleton),
               skeleton.isTracked {
                let matrix = matrix_multiply(anchor.originFromAnchorTransform, skeleton.anchorFromJointTransform)
                let transform = Transform(matrix: matrix)
                joint.move(to: transform)
            }
        }
    }

    private func updateDirection(from vector: SIMD3<Float>?) -> HSDirection {
        guard let vector = vector,
              length(vector) > 0.0001 else {
            return .any
        }

        // TODO: Rename and move this property to the HSDirection enum
        let referenceVectors: [HSDirection: SIMD3<Float>] = [
            .up: SIMD3(0, 1, 0),
            .down: SIMD3(0, -1, 0),
            .left: SIMD3(-1, 0, 0),
            .right: SIMD3(1, 0, 0),
            .front: SIMD3(0, 0, -1),
            .back: SIMD3(0, 0, 1)
        ]

        return referenceVectors.max(by: {
            dot(normalize(vector), $0.value) < dot(normalize(vector), $1.value)
        })?.key ?? .any
    }

    private func calculateFingerDirection() -> SIMD3<Float>? {
        if let tip = tip?.currentPosition,
           let knuckle = knuckle?.currentPosition {
            return normalize(tip - knuckle)
        }

        if let tip = intermediateTip?.currentPosition,
           let base = intermediateBase?.currentPosition {
            return normalize(tip - base)
        }

        return nil
    }

    private func getCurlAmount() async -> Float {
        // The order is important to calculate the curlness
        let jointsPositions = [
            tip?.currentPosition,
            intermediateTip?.currentPosition,
            intermediateBase?.currentPosition,
            knuckle?.currentPosition
        ].compactMap { $0 }

        return calculateCurlness(of: jointsPositions)
    }

    private func calculateCurlness(of joints: [SIMD3<Float>]) -> Float {
        guard joints.count >= 3 else {
            return 0
        }

        var totalCurl: Float = 0
        let segmentCount = joints.count - 2

        for index in 0..<segmentCount {
            let first = joints[index]
            let middle = joints[index + 1]
            let last = joints[index + 2]

            let vector1 = normalize(middle - first)
            let vector2 = normalize(last - middle)

            let angle = acos(dot(vector1, vector2))
            let curl = 1 - abs(angle - .pi) / .pi

            totalCurl += curl
        }

        return totalCurl / Float(segmentCount)
    }
}

public extension HSFinger {
    enum Name: String, CaseIterable, Sendable {
        case thumb
        case index
        case middle
        case ring
        case little
    }
}
