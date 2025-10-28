import ARKit

@MainActor
public protocol HSGestureScheme: AnyObject, Sendable {
    var chirality: HSChirality { get }
    var direction: HSDirection { get }
    var description: HSGestureDescription { get }

    var wasRecognized: Bool { get }

    var recognitionEvents: HSHandsEvents { get set }

    var leftEvent: HSHandEvent? { get }
    var rightEvent: HSHandEvent? { get }

    func recognize(in hand: HSHand) async
}

public extension HSGestureScheme {
    var leftEvent: HSHandEvent? { recognitionEvents.leftHand }
    var rightEvent: HSHandEvent? { recognitionEvents.rightHand }
    
    var wasRecognized: Bool {
        switch self.chirality {
        case .either:
            return (leftEvent?.wasRecognized ?? false) || (rightEvent?.wasRecognized ?? false)
        case .left:
            return leftEvent?.wasRecognized ?? false
        case .right:
            return rightEvent?.wasRecognized ?? false
        }
    }
    
    func recognize(in hand: HSHand) {
        guard case .hand(let direction, let fingers, let jointComparisons) = description else { return }
        
        let wasRecognized = fingers.allSatisfy { fingerDescription in
            let finger = hand.getFinger(named: fingerDescription.name)
            let curlnessAccepted = fingerDescription.state == .straight ? true : finger.curlness >= fingerDescription.curlness
            let stateAccepted = fingerDescription.state == .neutral ? true : finger.state == fingerDescription.state
            let directionHandAccepted = direction == .any ? true : hand.direction == direction
            let directionAccepted = fingerDescription.direction == .any ? true : finger.direction == fingerDescription.direction
            
            return curlnessAccepted && stateAccepted && directionAccepted && directionHandAccepted
        }
        
        let event: HSHandEvent
        
        if !jointComparisons.isEmpty {
            let areJointComparisonsValid = jointComparisons.allSatisfy { jointComparison in
                let firstFinger = hand.getFinger(named: jointComparison.firstFinger)
                let secondFinger = hand.getFinger(named: jointComparison.secondFinger)
                
                let firstJoint = firstFinger.joints[jointComparison.firstJoint]
                let secondJoint = secondFinger.joints[jointComparison.secondJoint]
                
                guard let firstJointPosition = firstJoint?.currentPosition,
                      let secondJointPosition = secondJoint?.currentPosition else {
                    return false
                }
                
                let calculatedDistance = firstJointPosition.distance(to: secondJointPosition)
                
                switch jointComparison.constraint {
                case .greaterThanOrEqualTo(let distance):
                    return calculatedDistance >= distance
                case .lessThanOrEqualTo(let distance):
                    return calculatedDistance <= distance
                }
            }
            event = HSHandEvent(wasRecognized: (wasRecognized && areJointComparisonsValid), hand: hand)
        } else {
            event = HSHandEvent(wasRecognized: wasRecognized, hand: hand)
        }
        
        if hand.chirality == .left {
            self.recognitionEvents.leftHand = event
        }
        
        if hand.chirality == .right {
            self.recognitionEvents.rightHand = event
        }
    }
}
