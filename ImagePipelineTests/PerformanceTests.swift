import XCTest
@testable import ImagePipeline

class PerformanceTests: XCTestCase {
    var pngData = [Data]()
    var jpegData = [Data]()
    var gifData = [Data]()
    var webpData = [Data]()

    override func setUp() {
        pngData.removeAll()
        jpegData.removeAll()
        gifData.removeAll()
        webpData.removeAll()

        for i in 1...99 {
            pngData.append(try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "\(i)", withExtension: "png")!))
            jpegData.append(try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "\(i)", withExtension: "jpg")!))
            gifData.append(try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "\(i)", withExtension: "gif")!))
            webpData.append(try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "\(i)", withExtension: "webp")!))
        }
    }

    func testDecodingPNGPerformance() {
        let decoder = Decoder()
        measure {
            pngData.forEach { _ = decoder.decode(data: $0) }
        }
    }

    func testDecodingJPEGPerformance() {
        let decoder = Decoder()
        measure {
            jpegData.forEach { _ = decoder.decode(data: $0) }
        }
    }

    func testDecodingGIFPerformance() {
        let decoder = Decoder()
        measure {
            gifData.forEach { _ = decoder.decode(data: $0) }
        }
    }

    func testDecodingWebPPerformance() {
        let decoder = Decoder()
        measure {
            webpData.forEach { _ = decoder.decode(data: $0) }
        }
    }
    
}
