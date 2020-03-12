import XCTest
import SnapshotTesting
@testable import ImagePipeline

class DecoderTests: XCTestCase {
    func testDecodePNG() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!)

        let decoder = ImageDecoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testDecodeJPEG() {
        if #available(iOS 13.0, *) {
            // Workaround for iOS 13 JPEG encoder change
            return
        }

        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "jpg")!)

        let decoder = ImageDecoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testDecodeJPEG_iOS13() {
        // Workaround for iOS 13 JPEG encoder change
        if #available(iOS 13.0, *) {
            let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "jpg")!)

            let decoder = ImageDecoder()
            guard let image = decoder.decode(data: fixture) else {
                XCTFail("image decode failed" )
                return
            }

            assertSnapshot(matching: image, as: .image)
        }
    }

    func testDecodeGIF() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "gif")!)

        let decoder = ImageDecoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }

    func testDecodeWebP() {
        let fixture = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "webp")!)

        let decoder = ImageDecoder()
        guard let image = decoder.decode(data: fixture) else {
            XCTFail("image decode failed" )
            return
        }

        assertSnapshot(matching: image, as: .image)
    }
}
