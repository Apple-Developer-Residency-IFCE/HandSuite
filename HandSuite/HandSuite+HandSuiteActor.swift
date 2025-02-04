//
//  HandSuite.swift
//  HandTracker
//
//  Created by Pedro Sousa on 26/11/24.
//

import Foundation

public struct HandSuiteTools {}

@globalActor
public actor HandSuiteActor: GlobalActor {
    public static let shared = HandSuiteActor()

    func run(_ action: () async -> Void) async {
        await action()
    }
}
