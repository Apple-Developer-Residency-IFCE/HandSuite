//
//  ModelEntity.swift
//  HandTracker
//
//  Created by Pedro Sousa on 25/11/24.
//

import SwiftUI
import RealityKit

public extension ModelEntity {
    static func createSphere(radius: Float = 0.005, hexColor: String = "FAF9F6") -> ModelEntity {
        let simpleMaterial = SimpleMaterial(color: UIColor(hex: hexColor), isMetallic: false)
        return ModelEntity(mesh: .generateSphere(radius: radius), materials: [simpleMaterial])
    }
    
    static private func animationDuration(for entity: Entity) -> TimeInterval? {
        entity.availableAnimations.first?.definition.duration
    }
    
    static func createAnimation(
        to content: RealityViewContent,
        name: String,
        bundle: Bundle,
        completion: @escaping (_ entity: Entity, _ anchor: AnchorEntity) -> Void
    ) {
        Task {
            do {
                let entity = try await Entity(named: name, in: bundle)
                let anchor = AnchorEntity(.hand(.right, location: .palm))

                entity.scale = SIMD3<Float>(repeating: 0.05)
                anchor.addChild(entity)

                await MainActor.run {
                    content.add(anchor)
                }

                if let animation = entity.availableAnimations.first {
                    // TODO: Create a Transform rotation function
                    entity.playAnimation(animation, transitionDuration: 0.1)
                }

                completion(entity, anchor)

            } catch {
                print("Erro ao carregar ou manipular animação: \(error)")
            }
        }
    }
    
    static func removeAnimation(from content: RealityViewContent, entity: Entity?, anchor: AnchorEntity?, completion: @escaping (_ removed: Bool) -> Void) {
        Task {
            var removed: Bool = false
            if let previousEntity = entity,
               let animDuration = animationDuration(for: previousEntity) {
                try? await Task.sleep(nanoseconds: UInt64(animDuration * 1_000_000_000))
            }

            await MainActor.run {
                if let anchor {
                    content.remove(anchor)
                    anchor.removeFromParent()
                }
                removed = true
                
            }
            
            completion(removed)
        }
    }
}

extension SIMD3: Sendable {}

public extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(color & 0x0000FF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
