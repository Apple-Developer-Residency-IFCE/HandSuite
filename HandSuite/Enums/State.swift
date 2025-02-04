//
//  State.swift
//  HandTracker
//
//  Created by Pedro Sousa on 27/11/24.
//

import Foundation

public extension HandSuiteTools {
    enum State: Int, CaseIterable {
        case neutral
        case straight
        case curl
    }
}
