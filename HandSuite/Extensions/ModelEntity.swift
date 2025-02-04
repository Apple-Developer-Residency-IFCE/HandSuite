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
