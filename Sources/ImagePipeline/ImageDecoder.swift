import UIKit
import CoreGraphics
import WebPDecoder

public protocol ImageDecoding {
    func decode(data: Data) -> UIImage?
}

public struct ImageDecoder: ImageDecoding {
    public init() {}

    public func decode(data: Data) -> UIImage? {
        guard data.count > 12 else {
            return nil
        }

        let bytes = Array(data)
        if isJPEG(bytes: bytes) || isPNG(bytes: bytes) || isGIF(bytes: bytes) {
            return UIImage(data: data)
        }

        guard isWebP(bytes: bytes) else {
            return nil
        }

        return data.withUnsafeBytes { (bytes: UnsafePointer<UInt8>) in
            var width: Int32 = 0
            var height: Int32 = 0

            guard WebPGetInfo(bytes, data.count, &width, &height) != 0 else {
                return nil
            }
            guard let raw = WebPDecodeRGBA(bytes, data.count, &width, &height) else {
                return nil
            }
            guard let provider = CGDataProvider(dataInfo: nil,
                                                data: raw,
                                                size: Int(width * height * 4),
                                                releaseData: { (_, data, _) in free(UnsafeMutableRawPointer(mutating: data)) }) else {
                return nil
            }

            let bitsPerComponent = 8
            let bitsPerPixel = bitsPerComponent * 4
            let bytesPerRow = Int(4 * width)
            let space = CGColorSpaceCreateDeviceRGB()
            let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.last.rawValue)
            guard let cgImage = CGImage(width: Int(width), height: Int(height),
                                        bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow,
                                        space: space, bitmapInfo: bitmapInfo,
                                        provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent) else {
                return nil
            }

            return UIImage(cgImage: cgImage)
        }
    }

    private func isJPEG(bytes: [UInt8]) -> Bool {
        return bytes[0...2] == [0xFF, 0xD8, 0xFF]
    }

    private func isPNG(bytes: [UInt8]) -> Bool {
        return bytes[0...3] == [0x89, 0x50, 0x4E, 0x47]
    }

    private func isGIF(bytes: [UInt8]) -> Bool {
        return bytes[0...2] == [0x47, 0x49, 0x46]
    }

    private func isWebP(bytes: [UInt8]) -> Bool {
        return bytes[8...11] == [0x57, 0x45, 0x42, 0x50]
    }
}
