//
//  HandSkeleton+JointName.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import Foundation
import ARKit

public extension HandSkeleton {
    static let reciprocal: [Hand.Finger.Name: [Hand.Joint.Name: HandSkeleton.JointName]] = [
        .thumb: [
            .tip: .thumbTip,
            .intermediateTip: .thumbIntermediateTip,
            .intermediateBase: .thumbIntermediateBase,
            .knuckle: .thumbKnuckle
        ],
        .index: [
            .tip: .indexFingerTip,
            .intermediateTip: .indexFingerIntermediateTip,
            .metacarpal: .indexFingerMetacarpal,
            .intermediateBase: .indexFingerIntermediateBase,
            .knuckle: .indexFingerKnuckle
        ],
        .middle: [
            .tip: .middleFingerTip,
            .intermediateTip: .middleFingerIntermediateTip,
            .metacarpal: .middleFingerMetacarpal,
            .intermediateBase: .middleFingerIntermediateBase,
            .knuckle: .middleFingerKnuckle
        ],
        .ring: [
            .tip: .ringFingerTip,
            .intermediateTip: .ringFingerIntermediateTip,
            .metacarpal: .ringFingerMetacarpal,
            .intermediateBase: .ringFingerIntermediateBase,
            .knuckle: .ringFingerKnuckle
        ],
        .little: [
            .tip: .littleFingerTip,
            .intermediateTip: .littleFingerIntermediateTip,
            .metacarpal: .littleFingerMetacarpal,
            .intermediateBase: .littleFingerIntermediateBase,
            .knuckle: .littleFingerKnuckle
        ]
    ]
}
