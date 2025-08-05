//
//  Delegate.swift
//  HandMove
//
//  Created by Levi Ribeiro on 05/08/25.
//

import HandSuite

protocol DelegateGesture:AnyObject{
    func whichGestureWasRecognized (_gesture: HandSuiteTools.HandGesture)
}
