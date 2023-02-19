//
//  PixelBufferPool.swift
//  AppleDeveloperKit
//
//  Created by Evan Xie on 2023/2/17.
//

#if canImport(CoreVideo)
import Foundation
import CoreVideo

public final class PixelBufferPool {
    fileprivate var auxAttributes: CFDictionary

    public let pool: CVPixelBufferPool
    public let pixelBufferAttributes: CFDictionary

    public let width: Int
    public let height: Int
    public let pixelFormat: OSType

    /// Create CVPixelBufferPool to manage the CVPixelBuffer allocation.
    ///
    /// - pixelBufferCount The maximum number of buffers allowed in the pixel buffer pool.
    /// Buffer pool can create only `pixelBufferCount` pixel buffers at most.
    ///
    /// - width The width of pixel buffer
    /// - height The height of pixel buffer
    /// - pixelFormat The pixel format of pixel buffer. eg, kCVPixelFormatType_32BGRA
    ///
    ///- Throws: `PixelBufferPool.Error.failToCreatePixelBufferPool(CVReturn)` if create failed.
    public init(pixelBufferCount: Int, width: Int, height: Int, pixelFormat: OSType) throws {
        self.width = width
        self.height = height
        self.pixelFormat = pixelFormat

        auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey: pixelBufferCount] as CFDictionary

        pixelBufferAttributes = [
            kCVPixelBufferPixelFormatTypeKey: pixelFormat,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height,
            kCVPixelBufferMetalCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
        ] as CFDictionary

        pool = try Self.createPool(pixelBufferAttrs: pixelBufferAttributes, bufferCount: pixelBufferCount)
        Self.preallocatePixelBuffers(pool: pool, bufferCount: pixelBufferCount)
    }

    /// Create pixel buffer from buffer pool.
    /// - Throws: `PixelBufferPool.Error.failToCreatePixelBufferPool(CVReturn)`, If the number of pixel buffer
    /// in buffer pool exceeds the the given `pixelBufferCount`
    public func createPixelBuffer() throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        let result = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(nil, pool, auxAttributes, &pixelBuffer)
        guard result == kCVReturnSuccess else {
            throw Error.failToCreatePixelBuffer(result)
        }
        return pixelBuffer!
    }

    /// Free all unused pixel buffers.
    public func flush() {
        CVPixelBufferPoolFlush(pool, CVPixelBufferPoolFlushFlags.excessBuffers)
    }

    /// For `CVReturn`, `OSStatus`, and so on, you can find the error code detail meaning from
    /// [Apple Error Codes Lookup](https://www.osstatus.com).
    public enum Error: Swift.Error {
        case failToCreatePixelBuffer(CVReturn)
        case failToCreatePixelBufferPool(CVReturn)
    }

}

fileprivate extension PixelBufferPool {

    static func createPool(pixelBufferAttrs: CFDictionary, bufferCount: Int) throws -> CVPixelBufferPool {
        var pool: CVPixelBufferPool? = nil
        let poolAttrs = [ kCVPixelBufferPoolMinimumBufferCountKey:  bufferCount ] as CFDictionary
        let result = CVPixelBufferPoolCreate(kCFAllocatorDefault, poolAttrs, pixelBufferAttrs as CFDictionary, &pool)
        guard result == kCVReturnSuccess else {
            throw Error.failToCreatePixelBufferPool(result)
        }
        return pool!
    }

    static func preallocatePixelBuffers(pool: CVPixelBufferPool, bufferCount: Int) {
        var pixelBuffers = [CVPixelBuffer]()
        let auxAttris = [ kCVPixelBufferPoolAllocationThresholdKey: bufferCount] as CFDictionary

        for _ in 0..<bufferCount {
            var pixelBuffer: CVPixelBuffer? = nil
            if CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pool, auxAttris, &pixelBuffer) == kCVReturnSuccess {
                pixelBuffers.append(pixelBuffer!)
            } else {
                print("PixelBufferPool preallocate pixel buffer failed.")
            }
        }
        pixelBuffers.removeAll()
    }

}
#endif
