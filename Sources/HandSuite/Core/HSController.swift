import SwiftUI
import ARKit
import RealityKit
import Combine

@Observable
public final class HSController: @unchecked Sendable {
    @ObservationIgnored private var cancellables = Set<AnyCancellable>()
    @ObservationIgnored private let leftSubject = PassthroughSubject<HandAnchor, Never>()
    @ObservationIgnored private let rightSubject = PassthroughSubject<HandAnchor, Never>()
    
    @ObservationIgnored private let session: ARKitSession
    @ObservationIgnored private let provider: HandTrackingProvider
    
    @MainActor private(set) var latestHandTracking: HSHandsEvents = .init()
    @MainActor @ObservationIgnored private var gestures: [any HSGestureScheme] = []
    
    public let leftHand = HSHand(chirality: .left)
    public let rightHand = HSHand(chirality: .right)
    
    public init(session: ARKitSession = .init(),
                provider: HandTrackingProvider = .init()) {
        self.session = session
        self.provider = provider
        self.setupPipelines()
    }
    
    private func setupPipelines() {
        let leftPublisher = leftSubject
            .collect(5)
            .throttle(for: .milliseconds(30), scheduler: DispatchQueue.global(), latest: true)
            .share()
            .eraseToAnyPublisher()

        let rightPublisher = rightSubject
            .collect(5)
            .throttle(for: .milliseconds(30), scheduler: DispatchQueue.global(), latest: true)
            .share()
            .eraseToAnyPublisher()

        
        leftPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in self.processGestures(for: .left) }
            }
            .store(in: &cancellables)
        
        rightPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { @MainActor in self.processGestures(for: .right) }
            }
            .store(in: &cancellables)
        
        
        //TODO: FUNÇÃO QUE COMBINA FRAMES DE AMBAS AS MÃOS PARA BIMANUAL GESTURES
//        Publishers.CombineLatest(leftPublisher, rightPublisher)
//
//            }
//            .store(in: &cancellables)
        
        
    }
    
    public func requestAuthorization() async {
        _ = await session.requestAuthorization(for: [.handTracking])
    }
    
    public func run() async {
        guard HandTrackingProvider.isSupported else { return }
        
        do {
            try await session.run([provider])
            for await update in provider.anchorUpdates {
                await handle(update)
            }
        } catch {
            print("HandSuite Error: \(error.localizedDescription)")
        }
    }
    
    private func handle(_ update: AnchorUpdate<HandAnchor>) async {
        switch update.event {
        case .updated:
            let anchor = update.anchor
            guard anchor.isTracked else { return }
            if anchor.chirality == .left {
                leftSubject.send(anchor)
                await leftHand.update(using: anchor)
            } else {
                rightSubject.send(anchor)
                await rightHand.update(using: anchor)
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
    public func install(gesture: any HSGestureScheme) {
        self.gestures.append(gesture)
    }
    
    @MainActor
    public func remove(gesture: any HSGestureScheme) {
        self.gestures.removeAll { $0 === gesture }
    }
    
    @MainActor
    private func processGestures(for chirality: HSChirality) {
        for gesture in gestures {
            switch gesture.chirality {
            case .left where chirality == .left:
                gesture.recognize(in: leftHand)
            case .right where chirality == .right:
                gesture.recognize(in: rightHand)
            case .either:
                if chirality == .left { gesture.recognize(in: leftHand) }
                if chirality == .right { gesture.recognize(in: rightHand) }
            default: break
            }
        }
    }
    //TODO: FUNCÃO PARA PROCESSAR/RECONHECER OS GESTOS BIMANUAIS
//    @MainActor
//    private func processBimanual(left: HandAnchor, right: HandAnchor) {
//
//        }
//    }
}
