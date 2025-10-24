//
//  State.swift
//  HandTracker
//
//  Created by Pedro Sousa on 27/11/24.
//

import Foundation

public extension HandSuiteTools {
    enum State: String, CaseIterable {
        case neutral
        case straight
        case curl
    }
}
