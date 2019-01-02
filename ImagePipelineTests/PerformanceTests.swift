import XCTest
import CommonCrypto
@testable import ImagePipeline

class PerformanceTests: XCTestCase {
    var pngData = [Data]()
    var jpegData = [Data]()
    var gifData = [Data]()
    var webpData = [Data]()

    var tempFile: String {
        return (NSTemporaryDirectory() as NSString).appendingPathComponent("temp.sqlite")
    }

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

    override func tearDown() {
        try? FileManager().removeItem(atPath: tempFile)
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

    func testSQLiteStorageSavePerformance() {
        let diskCache = DiskCache(storage: SQLiteStorage(fileProvider: TemporaryFileProvider(tempFile: tempFile)))

        measure {
            webpData.forEach {
                let url = URL(string: "https://example.com/\(UUID().uuidString)")!
                let now = Date()
                let entry = CacheEntry(url: url, data: $0, contentType: "image/webp", timeToLive: 86400, creationDate: now, modificationDate: now)
                diskCache.store(entry, for: url)
            }
        }
    }

    func testFileStorageSavePerformance() {
        let diskCache = DiskCache(storage: FileStorage(directory: URL(fileURLWithPath: tempFile).deletingLastPathComponent()))

        measure {
            webpData.forEach {
                let url = URL(string: "https://example.com/\(UUID().uuidString)")!
                let now = Date()
                let entry = CacheEntry(url: url, data: $0, contentType: "image/webp", timeToLive: 86400, creationDate: now, modificationDate: now)
                diskCache.store(entry, for: url)
            }
        }
    }

    func testSQLiteStorageLoadPerformance() {
        let diskCache = DiskCache(storage: SQLiteStorage(fileProvider: TemporaryFileProvider(tempFile: tempFile)))
        var keys = [URL]()
        var loaded = [CacheEntry]()

        webpData.forEach {
            let url = URL(string: "https://example.com/\(UUID().uuidString)")!
            let now = Date()
            let entry = CacheEntry(url: url, data: $0, contentType: "image/webp", timeToLive: 86400, creationDate: now, modificationDate: now)
            diskCache.store(entry, for: url)

            keys.append(url)
        }

        XCTAssertEqual(keys.count, webpData.count)

        measure {
            keys.forEach { loaded.append(diskCache.load(for: $0)!) }
        }

        print(loaded.count)
    }

    func testFileStorageLoadPerformance() {
        let diskCache = DiskCache(storage: FileStorage(directory: URL(fileURLWithPath: tempFile).deletingLastPathComponent()))
        var keys = [URL]()
        var loaded = [CacheEntry]()

        webpData.forEach {
            let url = URL(string: "https://example.com/\(UUID().uuidString)")!
            let now = Date()
            let entry = CacheEntry(url: url, data: $0, contentType: "image/webp", timeToLive: 86400, creationDate: now, modificationDate: now)
            diskCache.store(entry, for: url)

            keys.append(url)
        }

        XCTAssertEqual(keys.count, webpData.count)

        measure {
            keys.forEach { loaded.append(diskCache.load(for: $0)!) }
        }

        print(loaded.count)
    }

    struct TemporaryFileProvider: FileProvider {
        let tempFile: String
        var path: String { return tempFile }
    }


    class FileStorage: Storage {
        let directory: URL

        init(directory: URL) {
            self.directory = directory
            try! FileManager().createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }

        func store(_ entry: CacheEntry, for url: URL) {
            try! entry.data.write(to: path(for: url))
        }

        func load(for url: URL) -> CacheEntry? {
            let data = try! Data(contentsOf: path(for: url))
            let now = Date()
            return CacheEntry(url: url, data: data, contentType: "image/webp", timeToLive: 86400, creationDate: now, modificationDate: now)
        }

        func remove(for url: URL) {}
        func removeAll() {}

        func path(for url: URL) -> URL {
            return directory.appendingPathComponent(sha1(string: url.absoluteString))
        }

        private func sha1(string: String) -> String {
            let data = string.cString(using: .utf8)!
            let length = Int(CC_SHA1_DIGEST_LENGTH)
            var result: [UInt8] = Array(repeating: 0, count: length)
            CC_SHA1(data, CC_LONG(data.count - 1), &result)
            return (0..<length).reduce("") { $0 + String(format: "%02hhx", result[$1])}
        }
    }
}
