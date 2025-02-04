//
//  HandsTracking.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import ARKit
import RealityKit

public extension HandSuiteTools {
    @Observable
    final class Tracker: @unchecked Sendable {
        @ObservationIgnored private let session: ARKitSession
        @ObservationIgnored private let provider: HandTrackingProvider
        
        @MainActor private(set) var latestHandTracking: HandSuiteTools.HandsEvents = .init()
        @MainActor @ObservationIgnored private var gestures: [any HandSuiteTools.GestureScheme] = []
        
        public let leftHand = Hand(chirality: .left)
        public let rightHand = Hand(chirality: .right)
        
        public init(session: ARKitSession = .init(),
             provider: HandTrackingProvider = .init()) {
            self.session = session
            self.provider = provider
        }
        
        public func requestAuthorization() async {
            _ = await session.requestAuthorization(for: [.handTracking])
        }

        public func track() async {
            guard HandTrackingProvider.isSupported else { return }
            
            do {
                try await session.run([provider])
                for await update in provider.anchorUpdates {
                    await handle(update)
                }
            } catch {
                print("Error starting hand tracking: \(error)")
            }
            
        }

        private func handle(_ update: AnchorUpdate<HandAnchor>) async {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                guard anchor.isTracked else { return }
                
                if anchor.chirality == .left {
                    await self.leftHand.update(using: anchor)
                } else {
                    await self.rightHand.update(using: anchor)
                }
            default:
                break
            }
        }

        @MainActor
        public func addToContent(_ content: RealityKit.RealityViewContent) {
            leftHand.addToContet(content)
            rightHand.addToContet(content)
        }

        @MainActor
        public func install(gesture: any HandSuiteTools.GestureScheme) {
            self.gestures.append(gesture)
        }

        @MainActor
        public func processGestures() {
            for gesture in gestures {
                if gesture.chirality == .left {
                    Task { gesture.recognize(in: self.leftHand) }
                }

                if gesture.chirality == .right {
                    Task { gesture.recognize(in: self.rightHand) }
                }

                if gesture.chirality == .either {
                    Task { gesture.recognize(in: self.leftHand) }
                    Task { gesture.recognize(in: self.rightHand) }
                }
            }
        }
    }
}
