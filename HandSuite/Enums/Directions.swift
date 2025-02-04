//
//  Directions.swift
//  HandTracker
//
//  Created by Pedro Sousa on 27/11/24.
//

import Foundation

public extension HandSuiteTools {
    enum Direction: Int, CaseIterable {
        case any
        case up
        case down
        case front
        case back
        case left
        case right
    }
}
