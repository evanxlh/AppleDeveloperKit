//
//  CVPixelBuffer+MetalTexture.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/19.
//

import Foundation
import Metal
import CoreVideo
import simd

public enum MetalTexture {
    case bgra(MTLTexture)
    case yuv(YuvTexture)

    public var isYuv: Bool {
        return yuv != nil
    }

    public var isBgra: Bool {
        return bgra != nil
    }

    public var bgra: MTLTexture? {
        switch self {
        case .bgra(let texture):
            return texture
        default:
            return nil
        }
    }

    public var yuv: YuvTexture? {
        switch self {
        case .yuv(let texture):
            return texture
        default:
            return nil
        }
    }

}

public struct YuvTexture {

    /// Y texture
    public let lumaTexture: MTLTexture

    /// UV texture
    public let chromaTexture: MTLTexture

    /// The matrix that converts yuv to rgb.
    public let colorConversion: YuvToRgbColorConversion

    public init(lumaTexture: MTLTexture, chromaTexture: MTLTexture, colorConversion: YuvToRgbColorConversion) {
        self.lumaTexture = lumaTexture
        self.chromaTexture = chromaTexture
        self.colorConversion = colorConversion
    }
}

public struct YuvToRgbColorConversion: Equatable {
    public let matrix: float3x3
    public let offset: SIMD3<Float>

    private static let matrix601 = matrix_float3x3(columns: (
        vector_float3([Float](arrayLiteral: 1.164,  1.164, 1.164)),
        vector_float3([Float](arrayLiteral: 0.0, -0.392, 2.017)),
        vector_float3([Float](arrayLiteral: 1.596, -0.813,   0.0)))
    )

    private static let matrix601FullRange = matrix_float3x3(columns: (
        vector_float3([Float](arrayLiteral: 1.000,  1.000, 1.000)),
        vector_float3([Float](arrayLiteral: 0.000, -0.343, 1.765)),
        vector_float3([Float](arrayLiteral: 1.400, -0.711, 0.000)))
    )

    /// BT.709, which is the standard for HDTV.
    private static let matrix709 = matrix_float3x3(columns: (
        vector_float3([Float](arrayLiteral: 1.164,  1.164, 1.164)),
        vector_float3([Float](arrayLiteral: 0.0, -0.213, 2.112)),
        vector_float3([Float](arrayLiteral: 1.793, -0.533,   0.0)))
    )

    public static let k601 = YuvToRgbColorConversion(matrix: matrix601, offset: SIMD3<Float>(-(16.0/255.0), -0.5, -0.5))
    public static let k601FullRange = YuvToRgbColorConversion(matrix: matrix601FullRange, offset: SIMD3<Float>(0.0, -0.5, -0.5))
    public static let k709 = YuvToRgbColorConversion(matrix: matrix709, offset: SIMD3<Float>(-(16.0/255.0), -0.5, -0.5))

    public init(matrix: float3x3, offset: SIMD3<Float>) {
        self.matrix = matrix
        self.offset = offset
    }

    public static func == (lhs: YuvToRgbColorConversion, rhs: YuvToRgbColorConversion) -> Bool {
        return lhs.matrix == rhs.matrix && lhs.offset == rhs.offset
    }

}

// MARK: - Create MTLTexture(s) from CVPixelBuffer

public extension CVPixelBuffer {

    /// Load texture from CVPixelBuffer.
    func loadTexture(_ textureCache: CVMetalTextureCache) -> MetalTexture? {
        CVPixelBufferLockBaseAddress(self, .readOnly)
        defer {
            CVMetalTextureCacheFlush(textureCache, 0)
            CVPixelBufferUnlockBaseAddress(self, .readOnly)
        }

        let pixelFormat = CVPixelBufferGetPixelFormatType(self)
        switch pixelFormat {
        case kCVPixelFormatType_32BGRA:
            if let texture = loadBgraTexture(textureCache) {
                return MetalTexture.bgra(texture)
            }
            return nil

        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange,
        kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            guard CVPixelBufferGetPlaneCount(self) == 2 else {
                return nil
            }
            if let texture = loadYuvTexture(textureCache) {
                return MetalTexture.yuv(texture)
            }
            return nil

        default:
            return nil
        }
    }

    /// Load bgra8Unorm_srgb texture.
    private func loadBgraTexture(_ textureCache: CVMetalTextureCache) -> MTLTexture? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        var cvTexture: CVMetalTexture?

        let result = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, self, nil, .bgra8Unorm_srgb, width, height, 0, &cvTexture)
        guard result == kCVReturnSuccess, let texture = cvTexture else {
            return nil
        }
        return CVMetalTextureGetTexture(texture) ?? nil
    }

    /// Load yuv texture, CVPixelBuffer has two planar: y pand uv.
    private func loadYuvTexture(_ textureCache: CVMetalTextureCache) -> YuvTexture? {
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)

        // Must use two textures for create luma and chroma texture. A memory grows higher and higher
        // If only use one plane texture for creating luma and chroma texture.
        var plane1Texture: CVMetalTexture?
        var result = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, self, nil, .r8Unorm_srgb, width, height, 0, &plane1Texture)
        guard result == kCVReturnSuccess else {
            print("🟠 Create luma CVMetalTexture failed: CVReturn(\(result))")
            return nil
        }
        guard let plane1 = plane1Texture, let luma = CVMetalTextureGetTexture(plane1) else {
            print("🟠 Get luma MTLTexture failed")
            return nil
        }

        var plane2Texture: CVMetalTexture?
        result = CVMetalTextureCacheCreateTextureFromImage(nil, textureCache, self, nil, .rg8Unorm_srgb, width/2, height/2, 1, &plane2Texture)
        guard result == kCVReturnSuccess else {
            print("🟠 Create chroma CVMetalTexture failed: CVReturn(\(result))")
            return nil
        }
        guard let plane2 = plane2Texture, let chroma = CVMetalTextureGetTexture(plane2) else {
            print("🟠 Get chroma MTLTexture failed")
            return nil
        }

        let pixelFormat = CVPixelBufferGetPixelFormatType(self)
        let isFullRange = (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        let conversion: YuvToRgbColorConversion
        // ColorAttachment must takeUnretainedValue, or will crash later by dispatch_release.(Test on the iOS 12)

        if let colorAttachments = CVBufferGetAttachment(self, kCVImageBufferYCbCrMatrixKey, nil)?.takeUnretainedValue() {
            if CFStringCompare((colorAttachments as! CFString), kCVImageBufferYCbCrMatrix_ITU_R_601_4, .compareCaseInsensitive) == .compareEqualTo {
                conversion = isFullRange ? .k601FullRange : .k601
            } else {
                conversion = .k709
            }
        } else {
            conversion = .k709
        }
        return YuvTexture(lumaTexture: luma, chromaTexture: chroma, colorConversion: conversion)
    }

}
