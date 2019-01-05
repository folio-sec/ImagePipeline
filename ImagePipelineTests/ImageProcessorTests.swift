import XCTest
import SnapshotTesting
@testable import ImagePipeline

class ImageProcessorTests: XCTestCase {
    func testImageResizer() {
        let originalImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "1", withExtension: "png")!))!

        let targetSize = CGSize(width: 200, height: 150)
        let resizer = ImageResizer(targetSize: targetSize)
        let resizedImage = resizer.process(image: originalImage)

        XCTAssertEqual(resizedImage.size, targetSize)
    }

    func testImageResizerAspectFit() {
        let originalImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "1", withExtension: "png")!))!

        let targetSize = CGSize(width: 400, height: 400)
        let resizer = ImageResizer(targetSize: targetSize)
        let resizedImage = resizer.process(image: originalImage)

        XCTAssertEqual(resizedImage.size, targetSize)
        assertSnapshot(matching: resizedImage, as: .image)
    }

    func testImageResizerAspectFill() {
        let originalImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "1", withExtension: "png")!))!

        let targetSize = CGSize(width: 400, height: 400)
        let resizer = ImageResizer(targetSize: targetSize, contentMode: .aspectFill)
        let resizedImage = resizer.process(image: originalImage)

        XCTAssertEqual(resizedImage.size, targetSize)
        assertSnapshot(matching: resizedImage, as: .image)
    }

    func testImageResizerOpaque() {
        let originalImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "1", withExtension: "png")!))!

        let targetSize = CGSize(width: 400, height: 400)
        let resizer = ImageResizer(targetSize: targetSize, isOpaque: true, backgroundColor: .white)
        let resizedImage = resizer.process(image: originalImage)

        XCTAssertEqual(resizedImage.size, targetSize)
        assertSnapshot(matching: resizedImage, as: .image)
    }

    func testResizer() {
        let originalImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "resize", withExtension: "jpeg")!))!

        let scale: CGFloat = 2
        let size = CGSize(width: 375 * scale, height: 232 * scale)

        do {
            let resizer = ImageResizer(targetSize: size)
            let image = resizer.process(image: originalImage)

            assertSnapshot(matching: image, as: .image)
        }
        do {
            let resizer = ImageResizer(targetSize: size, contentMode: .aspectFill)
            let image = resizer.process(image: originalImage)

            assertSnapshot(matching: image, as: .image)
        }
    }

    func testBlurFilter() {
        let originalImage = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "resize", withExtension: "jpeg")!))!

        let scale: CGFloat = 2
        let size = CGSize(width: 375 * scale, height: 232 * scale)

        let resizer = ImageResizer(targetSize: size, contentMode: .aspectFill)

        do {
            let filter = BlurFilter(style: .dark)
            let processors: [ImageProcessing] = [resizer, filter]
            let image = processors.reduce(originalImage) { $1.process(image: $0) }
            assertSnapshot(matching: image, as: .image)
        }

        do {
            let filter = BlurFilter(style: .light)
            let processors: [ImageProcessing] = [resizer, filter]
            let image = processors.reduce(originalImage) { $1.process(image: $0) }
            assertSnapshot(matching: image, as: .image)
        }

        do {
            let filter = BlurFilter(style: .extraLight)
            let processors: [ImageProcessing] = [resizer, filter]
            let image = processors.reduce(originalImage) { $1.process(image: $0) }
            assertSnapshot(matching: image, as: .image)
        }
    }
}
