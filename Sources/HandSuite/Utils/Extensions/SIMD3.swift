import simd

extension SIMD3<Float> {
    public func distance(to point: SIMD3<Float>) -> Float {
        return length(self - point)
    }
}
