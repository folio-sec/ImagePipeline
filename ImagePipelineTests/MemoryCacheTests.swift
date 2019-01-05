import XCTest
@testable import ImagePipeline

class MemoryCacheTests: XCTestCase {
    func testMemoryCache() {
        let cache = MemoryCache()

        let image1 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let url1 = URL(string: "https://example.com/image1.png")!

        let image2 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!))!
        let url2 = URL(string: "https://example.com/image2.png")!

        cache.store(image1, for: url1)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))

        cache.store(image2, for: url2)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.store(image1, for: url2)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertEqual(image1, cache.load(for: url2))

        cache.store(image2, for: url2)

        XCTAssertEqual(image1, cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.store(image2, for: url1)

        XCTAssertEqual(image2, cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(image2, cache.load(for: url2))

        cache.remove(for: url2)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))
    }

    func testMemoryCacheAutomaticRemovalByCount() {
        let image0 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image1 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image2 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image3 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image4 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image5 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image6 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image7 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image8 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image9 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!

        let cache = MemoryCache()
        cache.countLimit = 4

        XCTAssertEqual(cache.countLimit, 4)

        cache.store(image0, for: URL(string: "https://example.com/image\(0)")!)
        cache.store(image1, for: URL(string: "https://example.com/image\(1)")!)
        cache.store(image2, for: URL(string: "https://example.com/image\(2)")!)
        cache.store(image3, for: URL(string: "https://example.com/image\(3)")!)
        cache.store(image4, for: URL(string: "https://example.com/image\(4)")!)
        cache.store(image5, for: URL(string: "https://example.com/image\(5)")!)
        cache.store(image6, for: URL(string: "https://example.com/image\(6)")!)
        cache.store(image7, for: URL(string: "https://example.com/image\(7)")!)
        cache.store(image8, for: URL(string: "https://example.com/image\(8)")!)
        cache.store(image9, for: URL(string: "https://example.com/image\(9)")!)

        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(0)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(1)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(2)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(3)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(4)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(5)")!))
        XCTAssertEqual(image6, cache.load(for: URL(string: "https://example.com/image\(6)")!))
        XCTAssertEqual(image7, cache.load(for: URL(string: "https://example.com/image\(7)")!))
        XCTAssertEqual(image8, cache.load(for: URL(string: "https://example.com/image\(8)")!))
        XCTAssertEqual(image9, cache.load(for: URL(string: "https://example.com/image\(9)")!))

        cache.removeAll()

        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(0)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(1)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(2)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(3)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(4)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(5)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(6)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(7)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(8)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(9)")!))
    }

    func testMemoryCacheAutomaticRemoval() {
        let image = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!

        let size = image.size
        let bytesPerRow = Int(size.width * 4)
        let cost = bytesPerRow * Int(size.height)

        let image0 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image1 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image2 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image3 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image4 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image5 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image6 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image7 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image8 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!
        let image9 = UIImage(data: try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!))!

        let cache = MemoryCache()
        cache.totalCostLimit = cost * 4

        XCTAssertEqual(cache.totalCostLimit, cost * 4)

        cache.store(image0, for: URL(string: "https://example.com/image\(0)")!)
        cache.store(image1, for: URL(string: "https://example.com/image\(1)")!)
        cache.store(image2, for: URL(string: "https://example.com/image\(2)")!)
        cache.store(image3, for: URL(string: "https://example.com/image\(3)")!)
        cache.store(image4, for: URL(string: "https://example.com/image\(4)")!)
        cache.store(image5, for: URL(string: "https://example.com/image\(5)")!)
        cache.store(image6, for: URL(string: "https://example.com/image\(6)")!)
        cache.store(image7, for: URL(string: "https://example.com/image\(7)")!)
        cache.store(image8, for: URL(string: "https://example.com/image\(8)")!)
        cache.store(image9, for: URL(string: "https://example.com/image\(9)")!)

        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(0)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(1)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(2)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(3)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(4)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(5)")!))
        XCTAssertEqual(image6, cache.load(for: URL(string: "https://example.com/image\(6)")!))
        XCTAssertEqual(image7, cache.load(for: URL(string: "https://example.com/image\(7)")!))
        XCTAssertEqual(image8, cache.load(for: URL(string: "https://example.com/image\(8)")!))
        XCTAssertEqual(image9, cache.load(for: URL(string: "https://example.com/image\(9)")!))

        cache.removeAll()

        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(0)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(1)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(2)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(3)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(4)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(5)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(6)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(7)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(8)")!))
        XCTAssertNil(cache.load(for: URL(string: "https://example.com/image\(9)")!))
    }
}
