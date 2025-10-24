//
//  GestureModel.swift
//  HandSuite
//
//  Created by Narely Lima de Oliveira on 08/05/25.
//
import Foundation
import HandSuite
import Combine

@MainActor
@Observable
class GestureModel {
    private var tracker: HandSuiteTools.Tracker
    private var cancellable: AnyCancellable?
    private var currentIndex = 0
    private var recognitionTask: Task<Void, Never>?
    private(set) var gestureSequence: [HandSuiteTools.HandGesture] = []
    
    var sequenceCompleted = false
    
    var currentGesture: HandSuiteTools.HandGesture? {
        guard gestureSequence.indices.contains(currentIndex) else { return nil }
        return gestureSequence[currentIndex]
    }
    
    init(gestureSequence: [HandSuiteTools.HandGesture], tracker: HandSuiteTools.Tracker) {
        self.tracker = tracker
        self.gestureSequence = gestureSequence
        installCurrentGesture()
        startRecognitionWatcher()
    }
    
    private func installCurrentGesture() {
        guard let gesture = currentGesture else { return }
        tracker.install(gesture: gesture)
    }
    
    private func removeCurrentGesture() {
        guard let gesture = currentGesture else { return }
        tracker.remove(gesture: gesture)
    }
    
    private func startRecognitionWatcher() {
        recognitionTask?.cancel()

        recognitionTask = Task {
            while !Task.isCancelled {
                guard let currentGesture = self.currentGesture else {
                    continue
                }

                if currentGesture.wasRecognized {
                    self.removeCurrentGesture()
                    self.currentIndex += 1
                    print("Gesto Reconhecido")

                    if self.currentIndex < self.gestureSequence.count {
                        self.installCurrentGesture()
                    } else {
                        self.sequenceCompleted = true
                        try? await Task.sleep(for: .seconds(0.3))
                        self.sequenceCompleted = false
                        self.resetSequence()
                    }

                    try? await Task.sleep(for: .seconds(0.5))
                } else {
                    try? await Task.sleep(for: .seconds(0.05))
                }
            }
        }
    }
    
    func resetSequence() {
        for gesture in gestureSequence {
            tracker.remove(gesture: gesture)
        }
        currentIndex = 0
        installCurrentGesture()
    }
}
