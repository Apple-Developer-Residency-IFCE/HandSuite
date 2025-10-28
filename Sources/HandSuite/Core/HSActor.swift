import Foundation

@globalActor
public actor HSActor: GlobalActor {
    public static let shared = HSActor()

    func run(_ action: () async -> Void) async {
        await action()
    }
}
