import Foundation
import Accelerate

public struct BlurFilter: ImageProcessing {
    public let blurRadius: CGFloat
    public let tintColor: UIColor?
    public let saturationDeltaFactor: CGFloat
    public let isOpaque: Bool

    public enum Style {
        case extraLight
        case light
        case dark
    }

    public init(blurRadius: CGFloat, saturationDeltaFactor: CGFloat = 1.8, tintColor: UIColor? = nil, isOpaque: Bool = false) {
        self.blurRadius = blurRadius
        self.tintColor = tintColor
        self.saturationDeltaFactor = saturationDeltaFactor
        self.isOpaque = isOpaque
    }

    public init(style: Style, isOpaque: Bool = false) {
        switch style {
        case .extraLight:
            self.init(blurRadius: 20, saturationDeltaFactor: 1.8, tintColor: UIColor(white: 0.97, alpha: 0.82), isOpaque: isOpaque)
        case .light:
            self.init(blurRadius: 30, saturationDeltaFactor: 1.8, tintColor: UIColor(white: 1, alpha: 0.3), isOpaque: isOpaque)
        case .dark:
            self.init(blurRadius: 20, saturationDeltaFactor: 1.8, tintColor: UIColor(white: 0.11, alpha: 0.73), isOpaque: isOpaque)
        }
    }

    public func process(image: UIImage) -> UIImage {
        let size = image.size
        let scale: CGFloat = 1

        guard size.width >= 1 && size.height >= 1 else {
            return image
        }
        guard let cgImage = image.cgImage else {
            return image
        }

        let width = Int(size.width)
        let height = Int(size.height)
        let space = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGImageAlphaInfo = isOpaque ? .noneSkipLast : .premultipliedLast
        guard var inputContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: bitmapInfo.rawValue) else {
            return image
        }

        inputContext.draw(cgImage, in: CGRect(origin: .zero, size: size))
        var input = vImage_Buffer(data: inputContext.data,
                                  height: UInt(inputContext.height),
                                  width: UInt(inputContext.width),
                                  rowBytes: inputContext.bytesPerRow)

        guard var outputContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: space, bitmapInfo: bitmapInfo.rawValue) else {
            return image
        }

        let hasBlur = blurRadius > CGFloat.ulpOfOne
        let hasSaturationChange = abs(saturationDeltaFactor - 1) > CGFloat.ulpOfOne

        if hasBlur || hasSaturationChange {
            var output = vImage_Buffer(data: outputContext.data,
                                       height: UInt(outputContext.height),
                                       width: UInt(outputContext.width),
                                       rowBytes: outputContext.bytesPerRow)

            if hasBlur {
                let inputRadius = blurRadius * scale
                let r = inputRadius * 3 * sqrt(2 * CGFloat.pi) / 4 + 0.5
                var radius = UInt32(floor(r))
                if (radius % 2 != 1) {
                    radius += 1; // force radius to be odd so that the three box-blur methodology works.
                }
                vImageBoxConvolve_ARGB8888(&input, &output, nil, 0, 0, radius, radius, UnsafePointer<UInt8>(bitPattern: 0), vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&output, &input, nil, 0, 0, radius, radius, UnsafePointer<UInt8>(bitPattern: 0), vImage_Flags(kvImageEdgeExtend))
                vImageBoxConvolve_ARGB8888(&input, &output, nil, 0, 0, radius, radius, UnsafePointer<UInt8>(bitPattern: 0), vImage_Flags(kvImageEdgeExtend))
            }

            if hasSaturationChange {
                let s = saturationDeltaFactor
                let divisor: CGFloat = 256
                let matrix = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1
                ].map { Int16(round($0 * divisor)) }

                if hasBlur {
                    swap(&input, &output)
                    swap(&inputContext, &outputContext)

                    vImageMatrixMultiply_ARGB8888(&input, &output, matrix, Int32(divisor), nil, nil, vImage_Flags(kvImageNoFlags))
                }
            }
        }

        if let tintColor = tintColor {
            outputContext.setFillColor(tintColor.cgColor)
            outputContext.fill(CGRect(origin: .zero, size: size))
        }

        guard let outputImage = outputContext.makeImage() else {
            return image
        }
        
        return UIImage(cgImage: outputImage)
    }
}
