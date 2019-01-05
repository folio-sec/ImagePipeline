import XCTest
@testable import ImagePipeline

class DiskCacheTests: XCTestCase {
    func testDiskCache() {
        let cache = DiskCache(storage: SQLiteStorage(fileProvider: InMemoryFileProvider()))

        let now = Date()

        let data1 = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "200x150", withExtension: "png")!)
        let url1 = URL(string: "https://example.com/image1.png")!
        let entry1 = CacheEntry(url: url1, data: data1, contentType: "image/jpeg", timeToLive: 2, creationDate: now, modificationDate: now)

        let data2 = try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "c0ffee", withExtension: "png")!)
        let url2 = URL(string: "https://example.com/image2.png")!
        let entry2 = CacheEntry(url: url2, data: data2, contentType: "image/jpeg", timeToLive: 2, creationDate: now, modificationDate: now)

        cache.store(entry1, for: url1)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))

        cache.store(entry2, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.store(entry1, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry1, cache.load(for: url2))

        cache.store(entry2, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.store(entry2, for: url1)

        XCTAssertEqual(entry2, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.remove(for: url1)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.remove(for: url2)

        XCTAssertNil(cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))

        cache.store(entry1, for: url1)
        cache.store(entry2, for: url2)

        XCTAssertEqual(entry1, cache.load(for: url1))
        XCTAssertEqual(entry2, cache.load(for: url2))

        cache.removeAll()

        XCTAssertNil(cache.load(for: url1))
        XCTAssertNil(cache.load(for: url2))
    }

    func testRemoveOutdated() {
        let tempFile = (NSTemporaryDirectory() as NSString).appendingPathComponent("temp-\(UUID().uuidString).sqlite")
        let cache = DiskCache(storage: SQLiteStorage(fileProvider: TemporaryFileProvider(tempFile: tempFile)))

        var keys = [URL]()
        var webpData = [Data]()
        let now = Date()
        for i in 1...99 {
            webpData.append(try! Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "\(i)", withExtension: "webp")!))
        }
        for i in 0..<50 {
            let url = URL(string: "https://example.com/\(UUID().uuidString)")!
            keys.append(url)

            let entry = CacheEntry(url: url, data: webpData[i], contentType: "image/webp", timeToLive: 2, creationDate: now, modificationDate: now)
            cache.store(entry, for: url)
        }
        for i in 50..<99 {
            let url = URL(string: "https://example.com/\(UUID().uuidString)")!
            keys.append(url)

            let entry = CacheEntry(url: url, data: webpData[i], contentType: "image/webp", timeToLive: 86400, creationDate: now, modificationDate: now)
            cache.store(entry, for: url)
        }

        XCTAssertEqual(keys.count, webpData.count)
        keys.forEach { XCTAssertEqual(cache.load(for: $0)?.contentType, "image/webp") }

        let size = try! FileManager().attributesOfItem(atPath: tempFile)[FileAttributeKey.size] as! Int64
        XCTAssertGreaterThan(size, 0)

        RunLoop.main.run(until: Date(timeIntervalSinceNow: 3))
        cache.removeOutdated()

        let removedSize = try! FileManager().attributesOfItem(atPath: tempFile)[FileAttributeKey.size] as! Int64
        XCTAssertEqual(size, removedSize)

        cache.compact()

        let compactionSize = try! FileManager().attributesOfItem(atPath: tempFile)[FileAttributeKey.size] as! Int64
        XCTAssertLessThan(compactionSize, size)

        try! FileManager().removeItem(atPath: tempFile)
    }
}
