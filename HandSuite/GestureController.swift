//
//  GestureController.swift
//  HandMove
//
//  Created by Levi Ribeiro on 05/08/25.
//

import HandSuite

class GestureController: @preconcurrency DelegateGesture {
    var gestureModel: GestureModel

    init(model: GestureModel) {
        self.gestureModel = model
    }

    @MainActor
    func whichGestureWasRecognized(_gesture: HandSuiteTools.HandGesture) {
        print("Recognized gesture: \(_gesture.gestureId)")
        gestureModel.lastRecognizedGesture = _gesture
    }
}

